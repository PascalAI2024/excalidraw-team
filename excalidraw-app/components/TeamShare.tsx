import React, { useState, useEffect } from 'react';
import { useAuth } from '@clerk/clerk-react';

const API_URL = import.meta.env.VITE_APP_BACKEND_URL || 'http://localhost:3001';

interface TeamShareProps {
  drawingId: string | null;
}

interface Share {
  id: string;
  permission: 'VIEW' | 'EDIT';
  sharedWith: {
    name: string | null;
    email: string;
  };
}

export const TeamShare: React.FC<TeamShareProps> = ({ drawingId }) => {
  const { getToken } = useAuth();
  const [shares, setShares] = useState<Share[]>([]);
  const [email, setEmail] = useState('');
  const [permission, setPermission] = useState<'VIEW' | 'EDIT'>('VIEW');
  const [showSharePanel, setShowSharePanel] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (drawingId) {
      loadShares();
    }
  }, [drawingId]);

  const loadShares = async () => {
    if (!drawingId) return;

    try {
      const token = await getToken();
      const response = await fetch(`${API_URL}/api/drawings/${drawingId}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (response.ok) {
        const drawing = await response.json();
        setShares(drawing.shares || []);
      }
    } catch (error) {
      console.error('Error loading shares:', error);
    }
  };

  const shareWithUser = async () => {
    if (!drawingId || !email) return;

    try {
      setLoading(true);
      const token = await getToken();
      const response = await fetch(`${API_URL}/api/drawings/${drawingId}/share`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ email, permission })
      });

      if (response.ok) {
        setEmail('');
        loadShares();
        alert('Drawing shared successfully!');
      } else {
        const error = await response.json();
        alert(`Failed to share: ${error.error}`);
      }
    } catch (error) {
      console.error('Error sharing drawing:', error);
      alert('Failed to share drawing');
    } finally {
      setLoading(false);
    }
  };

  const removeShare = async (shareId: string) => {
    if (!drawingId) return;

    try {
      const token = await getToken();
      const response = await fetch(`${API_URL}/api/drawings/${drawingId}/share/${shareId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (response.ok) {
        loadShares();
      }
    } catch (error) {
      console.error('Error removing share:', error);
      alert('Failed to remove share');
    }
  };

  if (!drawingId) return null;

  return (
    <div style={{
      position: 'fixed',
      top: '10px',
      left: '10px',
      zIndex: 10
    }}>
      <button
        onClick={() => setShowSharePanel(!showSharePanel)}
        style={{
          padding: '8px 16px',
          borderRadius: '4px',
          border: 'none',
          background: '#28a745',
          color: 'white',
          cursor: 'pointer',
          display: 'flex',
          alignItems: 'center',
          gap: '5px'
        }}
      >
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M13.5 1a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3zM11 2.5a2.5 2.5 0 1 1 .603 1.628l-6.718 3.12a2.499 2.499 0 0 1 0 1.504l6.718 3.12a2.5 2.5 0 1 1-.488.876l-6.718-3.12a2.5 2.5 0 1 1 0-3.256l6.718-3.12A2.5 2.5 0 0 1 11 2.5zm-8.5 4a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3zm11 5.5a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3z"/>
        </svg>
        Share with Team
      </button>

      {showSharePanel && (
        <div style={{
          position: 'absolute',
          top: '100%',
          left: 0,
          background: 'white',
          borderRadius: '8px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
          padding: '15px',
          minWidth: '350px',
          marginTop: '5px'
        }}>
          <h3 style={{ margin: '0 0 15px 0' }}>Share Drawing</h3>

          <div style={{ marginBottom: '15px' }}>
            <div style={{ display: 'flex', gap: '5px', marginBottom: '10px' }}>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Enter email address"
                style={{
                  flex: 1,
                  padding: '8px',
                  borderRadius: '4px',
                  border: '1px solid #ddd'
                }}
              />
              
              <select
                value={permission}
                onChange={(e) => setPermission(e.target.value as 'VIEW' | 'EDIT')}
                style={{
                  padding: '8px',
                  borderRadius: '4px',
                  border: '1px solid #ddd'
                }}
              >
                <option value="VIEW">Can View</option>
                <option value="EDIT">Can Edit</option>
              </select>
              
              <button
                onClick={shareWithUser}
                disabled={!email || loading}
                style={{
                  padding: '8px 16px',
                  borderRadius: '4px',
                  border: 'none',
                  background: '#007bff',
                  color: 'white',
                  cursor: email && !loading ? 'pointer' : 'not-allowed',
                  opacity: email && !loading ? 1 : 0.6
                }}
              >
                {loading ? 'Sharing...' : 'Share'}
              </button>
            </div>
          </div>

          {shares.length > 0 && (
            <div>
              <h4 style={{ margin: '0 0 10px 0' }}>Shared with:</h4>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '5px' }}>
                {shares.map((share) => (
                  <div
                    key={share.id}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      padding: '8px',
                      borderRadius: '4px',
                      border: '1px solid #eee',
                      gap: '10px'
                    }}
                  >
                    <div style={{ flex: 1 }}>
                      <div style={{ fontWeight: 'bold' }}>
                        {share.sharedWith.name || share.sharedWith.email}
                      </div>
                      <div style={{ fontSize: '12px', color: '#666' }}>
                        {share.sharedWith.email} • {share.permission}
                      </div>
                    </div>
                    
                    <button
                      onClick={() => removeShare(share.id)}
                      style={{
                        padding: '4px 8px',
                        borderRadius: '4px',
                        border: '1px solid #ddd',
                        background: 'white',
                        color: '#dc3545',
                        fontSize: '12px',
                        cursor: 'pointer'
                      }}
                    >
                      Remove
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
};