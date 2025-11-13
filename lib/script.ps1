# Tạo các thư mục con trực tiếp trong thư mục hiện tại (lib)
New-Item -ItemType Directory -Path "src", "generated"

# Tạo cấu trúc thư mục con bên trong 'src'
$srcSubDirs = @(
    "core/constants",
    "core/enums",
    "data/database",
    "data/models",
    "data/datasources/local",
    "data/datasources/remote",
    "domain/repositories",
    "domain/services",
    "presentation/providers",
    "presentation/screens",
    "presentation/widgets"
)

foreach ($dir in $srcSubDirs) {
    New-Item -ItemType Directory -Path "src/$dir" -Force | Out-Null
}

Write-Host "Cấu trúc thư mục đã được tạo thành công!"