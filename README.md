# Playwright MCP Docker Setup

A Docker containerized setup for running the Playwright MCP (Model Context Protocol) server, enabling browser automation through MCP connections.

## Overview

This project provides a Docker environment for running `@playwright/mcp` server, which allows AI models to interact with web browsers through the Model Context Protocol. The setup supports both headed (GUI) and headless modes, with configuration for WSL2/WSLg environments.

## Features

- 🐳 **Dockerized Playwright MCP Server**: Easy deployment and isolation
- 🖥️ **Headed Mode Support**: Visual browser automation with GUI
- 🔧 **Headless Mode Support**: Server-side browser automation
- 🛡️ **Security**: Non-root user execution
- ⚙️ **Configurable**: Environment-based configuration
- 🐧 **WSL2/WSLg Compatible**: Optimized for Windows Subsystem for Linux

## Prerequisites

- Docker and Docker Compose
- For headed mode: WSL2 with WSLg (Windows 11) or X11 forwarding setup
- `.env` file (see Configuration section)

## Quick Start

### Option 1: Using Pre-built Image from GitHub Container Registry

1. **Create environment file**:
   ```bash
   cp env.example .env
   # Edit .env with your preferred settings
   ```

2. **Update docker-compose.yml** to use the pre-built image:
   ```yaml
   services:
     playwright-mcp:
       image: ghcr.io/YOUR_USERNAME/playwright_mcp:latest
       container_name: playwright-mcp-server
       # ... rest of configuration
   ```

3. **Run the container**:
   ```bash
   docker-compose up
   ```

### Option 2: Build from Source

1. **Clone and navigate to the project**:
   ```bash
   git clone <repository-url>
   cd playwright_mcp
   ```

2. **Create environment file**:
   ```bash
   cp env.example .env
   # Edit .env with your preferred settings
   ```

3. **Build and run**:
   ```bash
   docker-compose up --build
   ```

4. **Connect your MCP client** to `localhost:8931` (or your configured port)

## Publishing to GitHub Container Registry

This project includes GitHub Actions workflow for automatically building and pushing Docker images to GitHub Container Registry (GHCR).

### Automatic Publishing

The workflow automatically publishes images when:
- Pushing to `main` or `master` branch
- Creating version tags (e.g., `v1.0.0`)
- Manual trigger via GitHub Actions UI

### Manual Publishing

To manually build and push to GHCR:

1. **Login to GHCR**:
   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
   ```

2. **Build and tag**:
   ```bash
   docker build -t ghcr.io/YOUR_USERNAME/playwright_mcp:latest .
   ```

3. **Push**:
   ```bash
   docker push ghcr.io/YOUR_USERNAME/playwright_mcp:latest
   ```

### Using Published Images

Once published, others can use your image by updating their `docker-compose.yml`:

```yaml
services:
  playwright-mcp:
    image: ghcr.io/YOUR_USERNAME/playwright_mcp:latest
    container_name: playwright-mcp-server
    # ... rest of configuration
```

### Image Tags

The workflow creates multiple tags:
- `latest` - Latest from main/master branch
- `v1.0.0` - Specific version tags
- `v1.0` - Major.minor version
- `v1` - Major version only
- `main` - Branch name for development builds

## Configuration

Create a `.env` file in the project root with the following variables:

```env
# MCP Server Configuration
MCP_HOST_PORT=8931
HEADLESS=false

# Display Configuration (for headed mode)
DISPLAY=:0
WAYLAND_DISPLAY=wayland-0
XDG_RUNTIME_DIR=/run/user/1000

# Volume Mount Paths (for WSL2/WSLg)
X11_HOST_PATH=/tmp/.X11-unix
WSLG_HOST_PATH=/mnt/wslg

# Optional Playwright Settings
ISOLATED=false
NOSANDBOX=false
VIEWPORT_SIZE=1920x1080
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MCP_HOST_PORT` | `8931` | Port for MCP server connection |
| `HEADLESS` | `false` | Run browser in headless mode |
| `DISPLAY` | `:0` | X11 display for headed mode |
| `WAYLAND_DISPLAY` | `wayland-0` | Wayland display for WSLg |
| `XDG_RUNTIME_DIR` | `/run/user/1000` | XDG runtime directory |
| `X11_HOST_PATH` | `/tmp/.X11-unix` | X11 socket path on host |
| `WSLG_HOST_PATH` | `/mnt/wslg` | WSLg mount path |
| `ISOLATED` | `false` | Run in isolated mode |
| `NOSANDBOX` | `false` | Disable browser sandbox |
| `VIEWPORT_SIZE` | - | Browser viewport size (e.g., `1920x1080`) |

## Usage Modes

### Headed Mode (Default)
Perfect for development and debugging with visual browser interaction:

```bash
# .env
HEADLESS=false
MCP_HOST_PORT=8931
```

### Headless Mode
Ideal for server environments and automated testing:

```bash
# .env
HEADLESS=true
MCP_HOST_PORT=8931
```

## Docker Commands

### Build and Run
```bash
# Build and start
docker-compose up --build

# Run in background
docker-compose up -d --build

# View logs
docker-compose logs -f
```

### Management
```bash
# Stop services
docker-compose down

# Rebuild without cache
docker-compose build --no-cache

# Execute commands in container
docker-compose exec playwright-mcp sh
```

## Troubleshooting

### Common Issues

1. **Permission Denied Errors**:
   - Ensure Docker has proper permissions
   - Check file ownership in mounted volumes

2. **Display Issues (Headed Mode)**:
   - Verify WSL2/WSLg is properly configured
   - Check DISPLAY environment variable
   - Ensure X11 forwarding is working

3. **Port Conflicts**:
   - Change `MCP_HOST_PORT` in `.env` if port 8931 is in use
   - Check for other services using the same port

4. **Browser Installation Issues**:
   - The Dockerfile installs Chrome automatically
   - For other browsers, modify the Dockerfile

### Debugging

```bash
# Check container logs
docker-compose logs playwright-mcp

# Access container shell
docker-compose exec playwright-mcp sh

# Test MCP connection
curl http://localhost:8931/health
```

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   MCP Client    │◄──►│  Docker Container │◄──►│   Web Browser   │
│                 │    │                  │    │                 │
│ - AI Model      │    │ - @playwright/mcp │    │ - Chrome        │
│ - MCP Protocol  │    │ - Entrypoint     │    │ - Playwright    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Security Considerations

- Container runs as non-root user (`playwright`)
- Browser sandbox is enabled by default
- Isolated mode available for enhanced security
- Volume mounts are read-only where possible

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with both headed and headless modes
5. Submit a pull request

## License

[Add your license information here]

## Deployment Instructions

### Step 1: Prepare Your Repository

1. **Push your code to GitHub**:
   ```bash
   git add .
   git commit -m "Add GHCR publishing workflow"
   git push origin main
   ```

2. **Create a version tag** (optional):
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

### Step 2: Configure GitHub Repository

1. **Enable GitHub Actions**: Go to your repository → Actions tab → Enable workflows
2. **Set repository visibility**: Make sure your repository is public or configure package permissions
3. **Configure package permissions**: Go to Settings → Actions → General → Workflow permissions

### Step 3: Publish to GHCR

The GitHub Actions workflow will automatically:
- Build multi-architecture images (linux/amd64, linux/arm64)
- Push to `ghcr.io/YOUR_USERNAME/playwright_mcp`
- Create appropriate tags based on branch/tag

### Step 4: Share Your Container

Once published, others can use your container by:

1. **Updating their docker-compose.yml**:
   ```yaml
   services:
     playwright-mcp:
       image: ghcr.io/YOUR_USERNAME/playwright_mcp:latest
       container_name: playwright-mcp-server
       # ... rest of configuration
   ```

2. **Or pulling directly**:
   ```bash
   docker pull ghcr.io/YOUR_USERNAME/playwright_mcp:latest
   ```

### Step 5: Package Management

- **View packages**: Go to your GitHub profile → Packages
- **Manage permissions**: Set package visibility (public/private)
- **Monitor usage**: Check download statistics and usage

## Support

For issues and questions:
- Check the troubleshooting section
- Review Docker and Playwright documentation
- Open an issue in the repository
