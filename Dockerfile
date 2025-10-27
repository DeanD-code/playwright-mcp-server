# Specify the base image with specific version for reproducibility
FROM mcr.microsoft.com/playwright:v1.54.2-noble

# Set working directory
WORKDIR /app

# Create non-root user for security with proper home directory
RUN addgroup --system playwright && \
    adduser --system --ingroup playwright --home /home/playwright playwright

# Install @playwright/mcp globally with specific version
RUN npm install -g @playwright/mcp@0.0.32

# Install Chrome browser and dependencies required by Playwright
# Install as root first, then copy to user directory
RUN npx playwright install chrome && npx playwright install-deps chrome

# Copy the entrypoint script and set permissions
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set up npm directories and change ownership in one layer
RUN mkdir -p /home/playwright/.npm && \
    chown -R playwright:playwright /app /home/playwright

# Copy Playwright browsers to user directory and set proper permissions
RUN mkdir -p /home/playwright/.cache/ms-playwright && \
    cp -r /root/.cache/ms-playwright/* /home/playwright/.cache/ms-playwright/ 2>/dev/null || true && \
    chown -R playwright:playwright /home/playwright/.cache

# Switch to non-root user
USER playwright

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Add labels for better container management
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="Playwright MCP Server for browser automation"
LABEL version="1.0.0"