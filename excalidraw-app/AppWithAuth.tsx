import React, { useState, useRef, useEffect } from 'react';
import { Excalidraw } from '@excalidraw/excalidraw';
import type { ExcalidrawImperativeAPI } from '@excalidraw/excalidraw/types';
import { 
  SignIn, 
  SignUp, 
  UserButton, 
  useAuth, 
  useUser 
} from '@clerk/clerk-react';
import { CloudStorage } from './components/CloudStorage';
import { TeamShare } from './components/TeamShare';
import { SharedWithMe } from './components/SharedWithMe';

export default function AppWithAuth() {
  const { isSignedIn, isLoaded } = useAuth();
  const { user } = useUser();
  const [excalidrawAPI, setExcalidrawAPI] = useState<ExcalidrawImperativeAPI | null>(null);
  const [currentDrawingId, setCurrentDrawingId] = useState<string | null>(null);
  const [showSignIn, setShowSignIn] = useState(true);

  // Load drawing from URL if shared
  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const drawingId = urlParams.get('drawing');
    if (drawingId && excalidrawAPI && isSignedIn) {
      // This will be handled by CloudStorage component
      setCurrentDrawingId(drawingId);
    }
  }, [excalidrawAPI, isSignedIn]);

  if (!isLoaded) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh',
        fontSize: '18px',
        color: '#666'
      }}>
        Loading...
      </div>
    );
  }

  if (!isSignedIn) {
    return (
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: '100vh',
        background: '#f5f5f5',
        padding: '20px'
      }}>
        <div style={{
          background: 'white',
          borderRadius: '12px',
          padding: '40px',
          boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
          maxWidth: '400px',
          width: '100%'
        }}>
          <h1 style={{
            textAlign: 'center',
            marginBottom: '30px',
            color: '#333'
          }}>
            Team Excalidraw
          </h1>
          
          <div style={{
            display: 'flex',
            gap: '10px',
            marginBottom: '20px',
            borderBottom: '1px solid #eee'
          }}>
            <button
              onClick={() => setShowSignIn(true)}
              style={{
                flex: 1,
                padding: '10px',
                border: 'none',
                background: 'none',
                cursor: 'pointer',
                borderBottom: showSignIn ? '2px solid #007bff' : 'none',
                color: showSignIn ? '#007bff' : '#666',
                fontWeight: showSignIn ? 'bold' : 'normal'
              }}
            >
              Sign In
            </button>
            <button
              onClick={() => setShowSignIn(false)}
              style={{
                flex: 1,
                padding: '10px',
                border: 'none',
                background: 'none',
                cursor: 'pointer',
                borderBottom: !showSignIn ? '2px solid #007bff' : 'none',
                color: !showSignIn ? '#007bff' : '#666',
                fontWeight: !showSignIn ? 'bold' : 'normal'
              }}
            >
              Sign Up
            </button>
          </div>
          
          {showSignIn ? (
            <SignIn afterSignInUrl="/" redirectUrl="/" />
          ) : (
            <SignUp afterSignUpUrl="/" redirectUrl="/" />
          )}
        </div>
      </div>
    );
  }

  const handleDrawingLoad = (drawingId: string) => {
    setCurrentDrawingId(drawingId);
  };

  return (
    <div style={{ height: '100vh', position: 'relative' }}>
      {/* User Profile */}
      <div style={{
        position: 'fixed',
        top: '10px',
        left: '50%',
        transform: 'translateX(-50%)',
        zIndex: 10,
        background: 'white',
        borderRadius: '8px',
        padding: '8px 16px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        display: 'flex',
        alignItems: 'center',
        gap: '10px'
      }}>
        <UserButton afterSignOutUrl="/" />
        <span style={{ fontWeight: 'bold' }}>
          {user?.firstName || user?.emailAddresses[0].emailAddress}
        </span>
      </div>

      {/* Excalidraw Canvas */}
      <Excalidraw
        excalidrawAPI={(api) => setExcalidrawAPI(api)}
        theme="light"
        name="Team Excalidraw"
      />

      {/* Cloud Storage */}
      <CloudStorage 
        excalidrawAPI={excalidrawAPI} 
        onDrawingLoad={handleDrawingLoad}
      />

      {/* Team Share */}
      <TeamShare drawingId={currentDrawingId} />

      {/* Shared with Me */}
      <SharedWithMe onLoadDrawing={handleDrawingLoad} />
    </div>
  );
}