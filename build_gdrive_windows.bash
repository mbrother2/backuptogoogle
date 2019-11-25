#!/bin/bash
DIR=$PWD

echo "Build your own gdrive!"
echo ""
echo "Read more: https://github.com/mbrother2/backuptogoogle/wiki/Create-own-Google-credential-step-by-step"
read -p " Your Google API client_id: " GG_CLIENT_ID
read -p " Your Google API client_secret: " GG_CLIENT_SECRET
echo ""
echo "Cloning gdrive project from Github..."
git clone https://github.com/gdrive-org/gdrive.git
cd $DIR/gdrive
sed -i "s#^const ClientId =.*#const ClientId = \"${GG_CLIENT_ID}\"#g" handlers_drive.go
sed -i "s#^const ClientSecret =.*#const ClientSecret = \"${GG_CLIENT_SECRET}\"#g" handlers_drive.go
echo ""
echo "Downloading go from Google..."
curl.exe -o go1.12.1.zip https://dl.google.com/go/go1.12.1.windows-amd64.zip
echo ""
echo "Extracting go1.12.1.zip, can take some minutes..."
unzip.exe -q go1.12.1.zip
echo ""
echo "Building gdrive.exe..."
$DIR/gdrive/go/bin/go.exe  get github.com/prasmussen/gdrive
env GOOS=windows GOARCH=amd64 $DIR/gdrive/go/bin/go.exe build -ldflags '-w -s'
echo "Your gdrive bin here:"
echo "$DIR/gdrive/gdrive.exe"
