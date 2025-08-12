const express = require("express");
const { createProxyMiddleware } = require("http-proxy-middleware");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 8080;

// reverse proxy to internal API service in the same namespace
app.use("/api", createProxyMiddleware({
  target: process.env.API_BASE || "http://api:8080",
  changeOrigin: false,
  pathRewrite: { "^/api": "" }
}));

app.get("/healthz", (_req, res) => res.json({ ok: true }));

app.use(express.static(path.join(__dirname, "public")));
app.get("*", (_req, res) => res.sendFile(path.join(__dirname, "public/index.html")));

app.listen(PORT, () => console.log(`Frontend listening on ${PORT}`));
