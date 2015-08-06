FROM iojs:2.5

RUN useradd -ms /bin/bash strong-pm \
    && chown -R strong-pm:strong-pm /usr/local \
    && su strong-pm -c "npm install -g strong-pm && npm cache clear"

# Set up some semblance of an environment
WORKDIR /home/strong-pm
ENV HOME=/home/strong-pm PORT=3000
ENV NODE_ENV=production

# Run as non-privileged user inside container
USER strong-pm

# Expose strong-pm port
EXPOSE 8701 3001

ENTRYPOINT ["/usr/local/bin/sl-pm", "--base", ".", "--listen", "8701"]
