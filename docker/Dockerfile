FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Override apt sources with Tsinghua mirror
RUN cat > /etc/apt/sources.list << 'EOF'
deb http://mirrors.tuna.tsinghua.edu.cn/debian bookworm main
deb http://mirrors.tuna.tsinghua.edu.cn/debian bookworm-updates main
deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main
EOF

# apt update
RUN apt update -qq

# install all build tools
RUN apt install -y -qq gcc python3-dev openjdk-17-jdk-headless maven patchelf

# clean apt cache
RUN apt clean && rm -rf /var/lib/apt/lists/*

# install uv
RUN pip install uv -q

WORKDIR /app
