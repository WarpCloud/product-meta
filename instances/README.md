## How to add new version

以发布tdc-2.0.0-final为例：

1. 安装verminator（Python 3.6+）

```bash
pip install -y verminator
```

2. 添加新版本（必需）
```bash
cd product-meta
verminator genver --releasemeta /path/to/releases_meta.yaml -v tdc-2.0.0-final instances
```

3. 验证新版本信息（必需）
```bash
verminator validate --releasemeta /path/to/releases_meta.yaml -v tdc-2.0.0-final instances
```

## How to validate instance integrity
```bash
verminator validate --releasemeta /path/to/releases_meta.yaml -v tdc-2.0.0-final instances
```