FROM node:4.4

RUN useradd -ms /bin/bash strong-pm \
    && chown -R strong-pm:strong-pm /usr/local \
    && su strong-pm -c "npm install -g strong-pm@5.0.1 && npm cache clear" \
    && apt-get update && apt-get install -y imagemagick libkrb5-dev

# Set up some semblance of an environment
WORKDIR /home/strong-pm
ENV HOME=/home/strong-pm PORT=3000
COPY ./etc/ImageMagick/policy.xml /etc/ImageMagick-6/policy.xml 
# Run as non-privileged user inside container
USER strong-pm

# Expose strong-pm port
EXPOSE 8701 3001

ENTRYPOINT ["/usr/local/bin/sl-pm", "--base", ".", "--listen", "8701"]
