application-templates
---------------------

## 添加新的App模板

### 命名规范

* 模板名称统一全大写，可以是字母，下划线_，和数字组合


### 目录结构

该README所在的目录为模板根目录，新增的App模板放置在`applications`子目录下。

目录结构形式：

```bash
NEW_APP
|___ [版本号]
      |___ test-files: 测试目录
      |___ dependency.jsonnet: 生成组件instance_list
      |___ resource.jsonnet: 定义组件的资源配置
```

### 测试文件

测试文件放在`test-files`目录下，命名规范为`config_[templateModule].jsonnet`，其中`templateModule`代表`dependency`, `resource`等模块名。

遵从此规范，可使用`run_test.sh`进行自动测试。


