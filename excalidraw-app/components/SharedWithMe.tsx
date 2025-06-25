import React, { useState, useEffect } from 'react';
import { useAuth } from '@clerk/clerk-react';

const API_URL = import.meta.env.VITE_APP_BACKEND_URL || 'http://localhost:3001';

interface SharedWithMeProps {
  onLoadDrawing: (drawingId: string) => void;
}

interface SharedDrawing {
  id: string;
  permission: 'VIEW' | 'EDIT';
  drawing: {
    id: string;
    title: string;
    thumbnail?: string;
    createdAt: string;
    updatedAt: string;
    user: {
      name: string | null;
      email: string;
    };
  };
}

export const SharedWithMe: React.FC<SharedWithMeProps> = ({ onLoadDrawing }) => {
  const { getToken } = useAuth();
  const [sharedDrawings, setSharedDrawings] = useState<SharedDrawing[]>([]);
  const [showPanel, setShowPanel] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadSharedDrawings();
  }, []);

  const loadSharedDrawings = async () => {
    try {
      setLoading(true);
      const token = await getToken();
      const response = await fetch(`${API_URL}/api/drawings/shared`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });

      if (response.ok) {
        const data = await response.json();
        setSharedDrawings(data);
      }
    } catch (error) {
      console.error('Error loading shared drawings:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      position: 'fixed',
      bottom: '10px',
      right: '10px',
      zIndex: 10
    }}>
      <button
        onClick={() => setShowPanel(!showPanel)}
        style={{
          padding: '8px 16px',
          borderRadius: '4px',
          border: 'none',
          background: '#6c757d',
          color: 'white',
          cursor: 'pointer',
          display: 'flex',
          alignItems: 'center',
          gap: '5px'
        }}
      >
        <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
          <path d="M7 14s-1 0-1-1 1-4 5-4 5 3 5 4-1 1-1 1H7zm4-6a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"/>
          <path fillRule="evenodd" d="M5.216 14A2.238 2.238 0 0 1 5 13c0-1.355.68-2.75 1.936-3.72A6.325 6.325 0 0 0 5 9c-4 0-5 3-5 4s1 1 1 1h4.216z"/>
          <path d="M4.5 8a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5z"/>
        </svg>
        Shared with Me ({sharedDrawings.length})
      </button>

      {showPanel && (
        <div style={{
          position: 'absolute',
          bottom: '100%',
          right: 0,
          background: 'white',
          borderRadius: '8px',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
          padding: '15px',
          minWidth: '350px',
          maxHeight: '400px',
          overflow: 'auto',
          marginBottom: '5px'
        }}>
          <h3 style={{ margin: '0 0 15px 0' }}>Shared with Me</h3>

          {loading ? (
            <p>Loading...</p>
          ) : sharedDrawings.length === 0 ? (
            <p style={{ color: '#666' }}>No drawings shared with you yet</p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {sharedDrawings.map((shared) => (
                <div
                  key={shared.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    padding: '10px',
                    borderRadius: '4px',
                    border: '1px solid #eee',
                    cursor: 'pointer',
                    transition: 'background 0.2s',
                    background: 'white'
                  }}
                  onClick={() => {
                    onLoadDrawing(shared.drawing.id);
                    setShowPanel(false);
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.background = '#f5f5f5';
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.background = 'white';
                  }}
                >
                  {shared.drawing.thumbnail && (
                    <img
                      src={shared.drawing.thumbnail}
                      alt={shared.drawing.title}
                      style={{
                        width: '50px',
                        height: '50px',
                        marginRight: '12px',
                        borderRadius: '4px',
                        objectFit: 'cover'
                      }}
                    />
                  )}

                  <div style={{ flex: 1 }}>
                    <div style={{ fontWeight: 'bold', marginBottom: '4px' }}>
                      {shared.drawing.title}
                    </div>
                    <div style={{ fontSize: '12px', color: '#666' }}>
                      Shared by {shared.drawing.user.name || shared.drawing.user.email}
                    </div>
                    <div style={{ fontSize: '11px', color: '#999' }}>
                      {new Date(shared.drawing.updatedAt).toLocaleDateString()} • {shared.permission}
                    </div>
                  </div>

                  <div style={{
                    padding: '4px 8px',
                    borderRadius: '4px',
                    background: shared.permission === 'EDIT' ? '#28a745' : '#6c757d',
                    color: 'white',
                    fontSize: '11px',
                    fontWeight: 'bold'
                  }}>
                    {shared.permission}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};