import React, { useState, useEffect } from 'react';
import { useAuth } from '@clerk/clerk-react';
import type { ExcalidrawImperativeAPI, BinaryFiles, BinaryFileData } from '@excalidraw/excalidraw/types';
import { exportToBlob } from '@excalidraw/excalidraw';

const API_URL = import.meta.env.VITE_APP_BACKEND_URL || 'http://localhost:3001';

interface CloudStorageProps {
  excalidrawAPI: ExcalidrawImperativeAPI | null;
  onDrawingLoad?: (drawingId: string) => void;
}

interface Drawing {
  id: string;
  title: string;
  thumbnail?: string;
  createdAt: string;
  updatedAt: string;
  isPublic: boolean;
}

export const CloudStorage: React.FC<CloudStorageProps> = ({ excalidrawAPI, onDrawingLoad }) => {
  const { getToken } = useAuth();
  const [drawings, setDrawings] = useState<Drawing[]>([]);
  const [currentDrawingId, setCurrentDrawingId] = useState<string | null>(null);
  const [title, setTitle] = useState('Untitled Drawing');
  const [showDrawingsList, setShowDrawingsList] = useState(false);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    loadDrawings();
  }, []);

  const loadDrawings = async () => {
    try {
      setLoading(true);
      const token = await getToken();
      const response = await fetch(`${API_URL}/api/drawings`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (response.ok) {
        const data = await response.json();
        setDrawings(data);
      }
    } catch (error) {
      console.error('Error loading drawings:', error);
    } finally {
      setLoading(false);
    }
  };

  const saveDrawing = async () => {
    if (!excalidrawAPI) return;
    
    try {
      setSaving(true);
      const token = await getToken();
      const elements = excalidrawAPI.getSceneElements();
      const appState = excalidrawAPI.getAppState();
      const files = excalidrawAPI.getFiles();
      
      // Convert files record to array
      const filesArray = Object.values(files);
      
      const content = {
        elements,
        appState: {
          viewBackgroundColor: appState.viewBackgroundColor,
          currentItemFontFamily: appState.currentItemFontFamily,
          zoom: appState.zoom,
          scrollX: appState.scrollX,
          scrollY: appState.scrollY
        },
        files: filesArray
      };
      
      // Generate thumbnail
      const blob = await exportToBlob({
        elements,
        appState,
        files,
        mimeType: 'image/png',
        getDimensions: () => ({ width: 400, height: 300, scale: 0.2 })
      });
      
      const reader = new FileReader();
      reader.readAsDataURL(blob);
      const thumbnail = await new Promise<string>((resolve) => {
        reader.onloadend = () => resolve(reader.result as string);
      });
      
      const body = {
        title,
        content,
        thumbnail,
        isPublic: false
      };
      
      const url = currentDrawingId 
        ? `${API_URL}/api/drawings/${currentDrawingId}`
        : `${API_URL}/api/drawings`;
        
      const method = currentDrawingId ? 'PUT' : 'POST';
      
      const response = await fetch(url, {
        method,
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
      });
      
      if (response.ok) {
        const savedDrawing = await response.json();
        setCurrentDrawingId(savedDrawing.id);
        loadDrawings();
        alert('Drawing saved successfully!');
      }
    } catch (error) {
      console.error('Error saving drawing:', error);
      alert('Failed to save drawing');
    } finally {
      setSaving(false);
    }
  };

  const loadDrawing = async (drawingId: string) => {
    if (!excalidrawAPI) return;
    
    try {
      const token = await getToken();
      const response = await fetch(`${API_URL}/api/drawings/${drawingId}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (response.ok) {
        const drawing = await response.json();
        const { elements, appState, files } = drawing.content;
        
        excalidrawAPI.updateScene({ elements, appState });
        
        if (files && files.length > 0) {
          // Files are already in the correct format from the server
          excalidrawAPI.addFiles(files as BinaryFileData[]);
        }
        
        setCurrentDrawingId(drawingId);
        setTitle(drawing.title);
        setShowDrawingsList(false);
        
        if (onDrawingLoad) {
          onDrawingLoad(drawingId);
        }
      }
    } catch (error) {
      console.error('Error loading drawing:', error);
      alert('Failed to load drawing');
    }
  };

  const deleteDrawing = async (drawingId: string) => {
    if (!confirm('Are you sure you want to delete this drawing?')) return;
    
    try {
      const token = await getToken();
      const response = await fetch(`${API_URL}/api/drawings/${drawingId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (response.ok) {
        if (drawingId === currentDrawingId) {
          setCurrentDrawingId(null);
          excalidrawAPI?.resetScene();
        }
        loadDrawings();
      }
    } catch (error) {
      console.error('Error deleting drawing:', error);
      alert('Failed to delete drawing');
    }
  };

  const createNewDrawing = () => {
    if (!excalidrawAPI) return;
    
    excalidrawAPI.resetScene();
    setCurrentDrawingId(null);
    setTitle('Untitled Drawing');
    setShowDrawingsList(false);
  };

  return (
    <div style={{
      position: 'fixed',
      top: '10px',
      right: '10px',
      zIndex: 10,
      background: 'white',
      borderRadius: '8px',
      boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
      padding: '10px',
      minWidth: '200px'
    }}>
      <div style={{ marginBottom: '10px' }}>
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Drawing title"
          style={{
            width: '100%',
            padding: '5px',
            borderRadius: '4px',
            border: '1px solid #ddd',
            marginBottom: '5px'
          }}
        />
        
        <div style={{ display: 'flex', gap: '5px' }}>
          <button
            onClick={saveDrawing}
            disabled={saving}
            style={{
              flex: 1,
              padding: '5px 10px',
              borderRadius: '4px',
              border: 'none',
              background: '#007bff',
              color: 'white',
              cursor: saving ? 'not-allowed' : 'pointer',
              opacity: saving ? 0.6 : 1
            }}
          >
            {saving ? 'Saving...' : currentDrawingId ? 'Update' : 'Save'}
          </button>
          
          <button
            onClick={() => setShowDrawingsList(!showDrawingsList)}
            style={{
              padding: '5px 10px',
              borderRadius: '4px',
              border: '1px solid #ddd',
              background: 'white',
              cursor: 'pointer'
            }}
          >
            My Drawings
          </button>
          
          <button
            onClick={createNewDrawing}
            style={{
              padding: '5px 10px',
              borderRadius: '4px',
              border: '1px solid #ddd',
              background: 'white',
              cursor: 'pointer'
            }}
          >
            New
          </button>
        </div>
      </div>
      
      {showDrawingsList && (
        <div style={{
          position: 'absolute',
          top: '100%',
          right: 0,
          background: 'white',
          borderRadius: '8px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
          padding: '10px',
          minWidth: '300px',
          maxHeight: '400px',
          overflow: 'auto',
          marginTop: '5px'
        }}>
          <h3 style={{ margin: '0 0 10px 0' }}>My Drawings</h3>
          
          {loading ? (
            <p>Loading...</p>
          ) : drawings.length === 0 ? (
            <p>No drawings yet</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '5px' }}>
              {drawings.map((drawing) => (
                <div
                  key={drawing.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    padding: '8px',
                    borderRadius: '4px',
                    border: '1px solid #eee',
                    cursor: 'pointer',
                    background: drawing.id === currentDrawingId ? '#f0f0f0' : 'white'
                  }}
                  onClick={() => loadDrawing(drawing.id)}
                >
                  {drawing.thumbnail && (
                    <img
                      src={drawing.thumbnail}
                      alt={drawing.title}
                      style={{
                        width: '40px',
                        height: '40px',
                        marginRight: '10px',
                        borderRadius: '4px',
                        objectFit: 'cover'
                      }}
                    />
                  )}
                  
                  <div style={{ flex: 1 }}>
                    <div style={{ fontWeight: 'bold' }}>{drawing.title}</div>
                    <div style={{ fontSize: '12px', color: '#666' }}>
                      {new Date(drawing.updatedAt).toLocaleDateString()}
                    </div>
                  </div>
                  
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      deleteDrawing(drawing.id);
                    }}
                    style={{
                      padding: '2px 6px',
                      borderRadius: '4px',
                      border: '1px solid #ddd',
                      background: 'white',
                      color: '#dc3545',
                      fontSize: '12px',
                      cursor: 'pointer'
                    }}
                  >
                    Delete
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};