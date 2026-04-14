# GitHub 上传操作指南（中文）

下面按 **最省事** 的路线写。你不需要自己重写文案，只需要把我给你的文件传上去。

## 一、先准备什么

你会拿到一个压缩包，名字建议保持为：

```text
retail-demand-modeling.zip
```

解压后会看到一个文件夹：

```text
retail-demand-modeling/
```

## 二、在 GitHub 上新建仓库

1. 登录 GitHub。
2. 右上角点击 `+`。
3. 点击 `New repository`。
4. 在 **Repository name** 里填：

```text
retail-demand-modeling
```

5. 在 **Description** 里填：

```text
Interpretable retail demand modeling with heterogeneity controls and time-aware validation.
```

6. 先选 `Private`。  
   不要一开始就公开，先自己检查一遍。
7. **不要勾选** `Add a README file`。  
   因为压缩包里已经有 README。
8. **不要勾选** `.gitignore` 和 license 模板。
9. 点击 `Create repository`。

## 三、上传文件

### 最简单方式
1. 进入新建好的仓库页面。
2. 点击 `uploading an existing file`，或者点 `Add file` → `Upload files`。
3. 把解压后的 `retail-demand-modeling` 文件夹里的**全部内容**拖进去。
4. 页面下方 `Commit changes` 保持默认即可。
5. 点击 `Commit changes`。

## 四、上传后先检查什么

上传完成后，先逐项检查：

### 1. 仓库首页
仓库首页最上面应该直接显示 `README.md` 内容。  
如果首页没有展示 README，说明你上传路径错了，可能多包了一层文件夹。

### 2. 目录结构
仓库根目录应当看到这些东西：

- `README.md`
- `.gitignore`
- `data/`
- `docs/`
- `notebooks/`
- `results/`
- `src/`

如果你看到的是：

```text
retail-demand-modeling/
  retail-demand-modeling/
    README.md
```

说明你把最外层文件夹整个拖上去了。  
这种情况要删掉重传。

## 五、哪些文件先不要上传

公开前，先不要上传这些旧文件：

- 你的原作业 PDF
- 学号命名的 `.Rmd`
- 题目 PDF
- 原始 `grocery.csv`，除非你明确确认可以公开分发

这一步很重要。否则仓库会显得像 coursework dump。

## 六、如果你要公开仓库，在哪里改

1. 进入仓库首页。
2. 点击最上方 `Settings`。
3. 左侧往下找到 `Danger Zone`。
4. 找到 `Change repository visibility`。
5. 选择 `Make public`。

只有在你确认下面三点后再公开：

- README 没有作业口吻
- 没有题目 PDF / 学号文件
- 没有未经确认可公开的数据文件

## 七、仓库首页 description、About、Topics 怎么填

在仓库右侧 `About` 区域点击齿轮图标。

### Description
填这句：

```text
Interpretable retail demand modeling with heterogeneity controls and time-aware validation.
```

### Website
如果没有个人主页，可以先留空。

### Topics
建议加这些：

```text
r
statistics
glm
demand-modeling
panel-data
forecasting
retail-analytics
count-data
```

## 八、README 不要自己乱改哪些地方

你可以改：
- 项目标题
- 第一段自我定位
- 末尾的 CV bullet

你不要改：
- 结果表里的核心数字
- “不是因果项目”的限制说明
- 不上传 raw data 的说明

这些地方一改坏，很容易显得不诚实或过度包装。

## 九、你上传完之后，最值得再做的一步

把仓库从 `Private` 先开给自己看一遍，然后问自己三个问题：

1. 这看起来像项目，还是像作业？
2. 我能不能用 30 秒讲清楚主结论？
3. 面试里如果别人问“为什么不是 causal claim”，我能不能接得住？

三个都答得上来，再公开。
