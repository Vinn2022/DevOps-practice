FROM ubuntu:20.04

# Set the working directory in the container
WORKDIR /app

# Set environmental variables to non-interactive to avoid apt-get prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    python3-pip \
    libdbus-1-dev \
    libdbus-glib-1-dev \
    python3-dev \
    curl \
    python3-venv \
    unzip \
    xdg-utils \
    openjdk-8-jre-headless \
    libxi6 \
    wget \
    gnupg \
    libcups2-dev \
    libgconf-2-4 \
    libnss3 \
    libxss1 \
    libappindicator1 \
    libindicator7 \
    apturl \
    distro-info \
    duplicity \
    language-selector-common \
    liblouis-data \
    liblouis-bin \
    python3-louis \
    python3-systemd \
    ubuntu-advantage-tools \
    ubuntu-drivers-common \
    usb-creator-gtk \
    python3-cairo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add Google Chrome's repository and install Google Chrome
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg wget curl unzip && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends google-chrome-stable && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    CHROME_VERSION=$(google-chrome --product-version) && \
    wget -q --continue -P /chromedriver "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$CHROME_VERSION/linux64/chromedriver-linux64.zip" && \
    unzip /chromedriver/chromedriver* -d /chromedriver/ && \
    cp /chromedriver/chromedriver-linux64/* /usr/local/bin/ && \
    rm -rf /chromedriver

# Verify if ChromeDriver and Chrome are installed correctly
RUN google-chrome --version && chromedriver --version

# Install Firefox and Geckodriver
# Install dependencies including wget, and Firefox
RUN apt-get update && \
    apt-get install -y wget unzip firefox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install GeckoDriver
RUN GECKODRIVER_VERSION=$(curl -sS https://api.github.com/repos/mozilla/geckodriver/releases/latest | grep '"tag_name"' | cut -d '"' -f 4) && \
    wget -O /tmp/geckodriver.tar.gz "https://github.com/mozilla/geckodriver/releases/download/$GECKODRIVER_VERSION/geckodriver-$GECKODRIVER_VERSION-linux64.tar.gz" && \
    tar -xzf /tmp/geckodriver.tar.gz -C /usr/local/bin/ && \
    rm /tmp/geckodriver.tar.gz && \
    chmod +x /usr/local/bin/geckodriver

# Verify if Firefox and GeckoDriver are installed correctly
RUN firefox --version && geckodriver --version

# Create and activate a virtual environment
RUN python3 -m venv venv
RUN . venv/bin/activate

# Install Python dependencies
COPY ./requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

# Set the entry point for the container
ENTRYPOINT ["/bin/bash"]