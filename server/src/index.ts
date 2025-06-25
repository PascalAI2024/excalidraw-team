import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { clerkClient } from '@clerk/clerk-sdk-node';
import { PrismaClient } from '../../generated/prisma';

// Load environment variables
dotenv.config({ path: '../.env.local' });
dotenv.config({ path: './.env' });

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3001;

app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true
}));

app.use(express.json({ limit: '50mb' }));

// Middleware to verify Clerk authentication
const requireAuth = async (req: any, res: any, next: any) => {
  try {
    const sessionToken = req.headers.authorization?.split(' ')[1];
    if (!sessionToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const session = await clerkClient.sessions.verifySession(sessionToken, sessionToken);
    const user = await clerkClient.users.getUser(session.userId);
    
    // Create or update user in database
    const dbUser = await prisma.user.upsert({
      where: { clerkId: user.id },
      update: { email: user.emailAddresses[0].emailAddress },
      create: {
        clerkId: user.id,
        email: user.emailAddresses[0].emailAddress,
        name: `${user.firstName || ''} ${user.lastName || ''}`.trim() || null
      }
    });
    
    req.user = dbUser;
    next();
  } catch (error) {
    console.error('Auth error:', error);
    res.status(401).json({ error: 'Unauthorized' });
  }
};

// Get all drawings for the authenticated user
app.get('/api/drawings', requireAuth, async (req: any, res) => {
  try {
    const drawings = await prisma.drawing.findMany({
      where: { userId: req.user.id },
      orderBy: { updatedAt: 'desc' },
      select: {
        id: true,
        title: true,
        thumbnail: true,
        createdAt: true,
        updatedAt: true,
        isPublic: true
      }
    });
    
    res.json(drawings);
  } catch (error) {
    console.error('Error fetching drawings:', error);
    res.status(500).json({ error: 'Failed to fetch drawings' });
  }
});

// Get shared drawings
app.get('/api/drawings/shared', requireAuth, async (req: any, res) => {
  try {
    const sharedDrawings = await prisma.share.findMany({
      where: { sharedWithId: req.user.id },
      include: {
        drawing: {
          select: {
            id: true,
            title: true,
            thumbnail: true,
            createdAt: true,
            updatedAt: true,
            user: {
              select: {
                name: true,
                email: true
              }
            }
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });
    
    res.json(sharedDrawings);
  } catch (error) {
    console.error('Error fetching shared drawings:', error);
    res.status(500).json({ error: 'Failed to fetch shared drawings' });
  }
});

// Get a specific drawing
app.get('/api/drawings/:id', requireAuth, async (req: any, res) => {
  try {
    const { id } = req.params;
    
    const drawing = await prisma.drawing.findFirst({
      where: {
        id,
        OR: [
          { userId: req.user.id },
          { shares: { some: { sharedWithId: req.user.id } } },
          { isPublic: true }
        ]
      },
      include: {
        user: {
          select: {
            name: true,
            email: true
          }
        },
        shares: {
          include: {
            sharedWith: {
              select: {
                name: true,
                email: true
              }
            }
          }
        }
      }
    });
    
    if (!drawing) {
      return res.status(404).json({ error: 'Drawing not found' });
    }
    
    res.json(drawing);
  } catch (error) {
    console.error('Error fetching drawing:', error);
    res.status(500).json({ error: 'Failed to fetch drawing' });
  }
});

// Create a new drawing
app.post('/api/drawings', requireAuth, async (req: any, res) => {
  try {
    const { title, content, thumbnail, isPublic } = req.body;
    
    const drawing = await prisma.drawing.create({
      data: {
        title: title || 'Untitled Drawing',
        content: content || {},
        thumbnail,
        isPublic: isPublic || false,
        userId: req.user.id
      }
    });
    
    res.json(drawing);
  } catch (error) {
    console.error('Error creating drawing:', error);
    res.status(500).json({ error: 'Failed to create drawing' });
  }
});

// Update a drawing
app.put('/api/drawings/:id', requireAuth, async (req: any, res) => {
  try {
    const { id } = req.params;
    const { title, content, thumbnail, isPublic } = req.body;
    
    // Check if user has permission to edit
    const existingDrawing = await prisma.drawing.findFirst({
      where: {
        id,
        OR: [
          { userId: req.user.id },
          { shares: { some: { sharedWithId: req.user.id, permission: 'EDIT' } } }
        ]
      }
    });
    
    if (!existingDrawing) {
      return res.status(403).json({ error: 'Permission denied' });
    }
    
    const drawing = await prisma.drawing.update({
      where: { id },
      data: {
        title,
        content,
        thumbnail,
        isPublic,
        updatedAt: new Date()
      }
    });
    
    res.json(drawing);
  } catch (error) {
    console.error('Error updating drawing:', error);
    res.status(500).json({ error: 'Failed to update drawing' });
  }
});

// Delete a drawing
app.delete('/api/drawings/:id', requireAuth, async (req: any, res) => {
  try {
    const { id } = req.params;
    
    // Only owner can delete
    const drawing = await prisma.drawing.findFirst({
      where: {
        id,
        userId: req.user.id
      }
    });
    
    if (!drawing) {
      return res.status(403).json({ error: 'Permission denied' });
    }
    
    await prisma.drawing.delete({
      where: { id }
    });
    
    res.json({ message: 'Drawing deleted successfully' });
  } catch (error) {
    console.error('Error deleting drawing:', error);
    res.status(500).json({ error: 'Failed to delete drawing' });
  }
});

// Share a drawing
app.post('/api/drawings/:id/share', requireAuth, async (req: any, res) => {
  try {
    const { id } = req.params;
    const { email, permission } = req.body;
    
    // Check if user owns the drawing
    const drawing = await prisma.drawing.findFirst({
      where: {
        id,
        userId: req.user.id
      }
    });
    
    if (!drawing) {
      return res.status(403).json({ error: 'Permission denied' });
    }
    
    // Find user to share with
    const userToShare = await prisma.user.findUnique({
      where: { email }
    });
    
    if (!userToShare) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Create or update share
    const share = await prisma.share.upsert({
      where: {
        drawingId_sharedWithId: {
          drawingId: id,
          sharedWithId: userToShare.id
        }
      },
      update: { permission },
      create: {
        drawingId: id,
        sharedWithId: userToShare.id,
        permission: permission || 'VIEW'
      }
    });
    
    res.json(share);
  } catch (error) {
    console.error('Error sharing drawing:', error);
    res.status(500).json({ error: 'Failed to share drawing' });
  }
});

// Remove share
app.delete('/api/drawings/:id/share/:shareId', requireAuth, async (req: any, res) => {
  try {
    const { id, shareId } = req.params;
    
    // Check if user owns the drawing
    const drawing = await prisma.drawing.findFirst({
      where: {
        id,
        userId: req.user.id
      }
    });
    
    if (!drawing) {
      return res.status(403).json({ error: 'Permission denied' });
    }
    
    await prisma.share.delete({
      where: { id: shareId }
    });
    
    res.json({ message: 'Share removed successfully' });
  } catch (error) {
    console.error('Error removing share:', error);
    res.status(500).json({ error: 'Failed to remove share' });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  await prisma.$disconnect();
  process.exit(0);
});