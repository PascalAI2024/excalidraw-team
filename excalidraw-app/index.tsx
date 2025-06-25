import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { registerSW } from "virtual:pwa-register";
import { ClerkProvider } from "./ClerkProvider";

import "../excalidraw-app/sentry";

import AppWithAuth from "./AppWithAuth";

window.__EXCALIDRAW_SHA__ = import.meta.env.VITE_APP_GIT_SHA;
const rootElement = document.getElementById("root")!;
const root = createRoot(rootElement);
registerSW();
root.render(
  <StrictMode>
    <ClerkProvider>
      <AppWithAuth />
    </ClerkProvider>
  </StrictMode>,
);