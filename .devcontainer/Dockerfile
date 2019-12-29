# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# Docker image file that describes an Alpine3.8 image with PowerShell installed from .tar.gz file(s)

# Define arg(s) needed for the From statement
ARG fromTag=4.0.0
ARG imageRepo=jekyll/jekyll

FROM ${imageRepo}:${fromTag} AS installer-env

# Define Args for the needed to add the package
ARG PS_VERSION=6.2.0
ARG PS_PACKAGE=powershell-${PS_VERSION}-linux-alpine-x64.tar.gz
ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}
ARG PS_INSTALL_VERSION=6

# define the folder we will be installing PowerShell to
ENV PS_INSTALL_FOLDER=/opt/microsoft/powershell/$PS_INSTALL_VERSION

# Create the install folder
RUN mkdir -p ${PS_INSTALL_FOLDER}

# Download the Linux tar.gz and save it
# ADD ${PS_PACKAGE_URL} /tmp/linux.tar.gz
# Unzip the Linux tar.gz
RUN wget -O /tmp/linux.tar.gz ${PS_PACKAGE_URL}
RUN tar zxf /tmp/linux.tar.gz -C ${PS_INSTALL_FOLDER} -v

# Start a new stage so we lose all the tar.gz layers from the final image
FROM ${imageRepo}:${fromTag}

# Copy only the files we need from the previous stage
COPY --from=installer-env ["/opt/microsoft/powershell", "/opt/microsoft/powershell"]

# Define Args and Env needed to create links
ARG PS_INSTALL_VERSION=6
ENV PS_INSTALL_FOLDER=/opt/microsoft/powershell/$PS_INSTALL_VERSION \
    \
    # Define ENVs for Localization/Globalization
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    # set a fixed location for the Module analysis cache
    PSModuleAnalysisCachePath=/var/cache/microsoft/powershell/PSModuleAnalysisCache/ModuleAnalysisCache

# Install gpg2, ssh, and socat for socket connect to Windows
RUN apk add --no-cache socat \
  gnupg \
  openssh \
  && mkdir -p /root/.gnupg \
  && chmod 700 /root/.gnupg

# Install dotnet dependencies and ca-certificates
RUN apk -X http://dl-cdn.alpinelinux.org/alpine/v3.8/main add --no-cache ca-certificates less \
    # PSReadline/console dependencies
    ncurses-terminfo-base \
    # .NET Core dependencies
    krb5-libs \
    libgcc \
    libintl \
    libssl1.0 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs \
    && apk -X http://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
    lttng-ust \
    # Create the pwsh symbolic link that points to powershell
    && ln -s ${PS_INSTALL_FOLDER}/pwsh /usr/bin/pwsh \
    # Give all user execute permissions and remove write permissions for others
    && chmod a+x,o-w ${PS_INSTALL_FOLDER}/pwsh \
    # intialize powershell module cache
    && pwsh \
        -NoLogo \
        -NoProfile \
        -Command " \
          \$ErrorActionPreference = 'Stop' ; \
          \$ProgressPreference = 'SilentlyContinue' ; \
          while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) {  \
            Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
            Start-Sleep -Seconds 6 ; \
          }"

# Install powershell theme
RUN pwsh -NoLogo -NoProfile -Command " \
  Install-Module posh-git -Scope AllUsers -Force; \
  Install-Module oh-my-posh -Scope AllUsers -Force; \
  Install-Module devtoolbox -Scope AllUsers -Force"

COPY .bashrc /root
COPY profile.ps1 /opt/microsoft/powershell/6/profile.ps1

ENV ENV="/root/.bashrc"
