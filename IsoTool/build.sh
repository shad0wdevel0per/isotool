#!/bin/bash

echo "🔧 Limpando..."
rm -rf build IsoTool.app

echo "📦 Criando estrutura..."
mkdir -p build
mkdir -p IsoTool.app/Contents/MacOS
mkdir -p IsoTool.app/Contents/Resources

echo "🛠 Compilando..."
swiftc -O main.swift -o build/IsoTool

cp build/IsoTool IsoTool.app/Contents/MacOS/
cp Resources/IsoToolIcon.icns IsoTool.app/Contents/Resources/
cp Info.plist IsoTool.app/Contents/

echo "✅ Build concluído! IsoTool.app pronto."