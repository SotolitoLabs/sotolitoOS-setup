#!/bin/bash

# Build the sotolitoos release package

cp files/* ~/rpmbuild/SOURCES
rpmbuild -ba sotlitoos-release.spec
