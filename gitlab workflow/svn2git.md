# svn项目迁移至git

- [svn项目迁移至git](#svn%E9%A1%B9%E7%9B%AE%E8%BF%81%E7%A7%BB%E8%87%B3git)
  - [方案说明](#%E6%96%B9%E6%A1%88%E8%AF%B4%E6%98%8E)
  - [Cut over migration](#cut-over-migration)
    - [svn authors转Git authors](#svn-authors%E8%BD%ACgit-authors)
    - [使用svn2git转换项目](#%E4%BD%BF%E7%94%A8svn2git%E8%BD%AC%E6%8D%A2%E9%A1%B9%E7%9B%AE)
    - [提交本地git至远程仓库](#%E6%8F%90%E4%BA%A4%E6%9C%AC%E5%9C%B0git%E8%87%B3%E8%BF%9C%E7%A8%8B%E4%BB%93%E5%BA%93)
  - [svn2git使用期间故障处理](#svn2git%E4%BD%BF%E7%94%A8%E6%9C%9F%E9%97%B4%E6%95%85%E9%9A%9C%E5%A4%84%E7%90%86)
  - [参考](#%E5%8F%82%E8%80%83)

相信大部分的互联网企业在新建项目时都会选择git作为代码仓库，svn在分支管理、协作管理以及项目的CI/CD集成方面都不如git，但是在权限控制，非代码的版本控制方面，svn仍具有非常大的优势，所以仍将继续存在很长一段时间。

回到svn项目迁移话题，这个可能是从git诞生开始就存在的一个需求，官网给出两套解决方案：`Git/SVN Mirro`和`Cut over migration`

## 方案说明

1. Git/SVN Mirror:
   - 制作一个SVN项目的Git仓库镜像
   - 保持Git和SVN仓库保持同步，你可以选择使用任何一个仓库。
   - 平滑迁移处理同时可以管理迁移风险
2. Cut over migration which:
   - 转换并导入SVN项目中已存在的数据和历史信息至Git。
   - 方案适用于小规模的团队，一次性迁移。

针对公司现有SVN上代码情况和团队规模来看，一次迁移更加符合要求同时后续管理成本更低，所以后续主要针对`Cut over migration`方案更加符合需求

## Cut over migration

此方案无法保证迁移后svn和git仓库的持续同步，因此采用此方案需要所有开发团队成员在硬切分迁移后全部转为使用git仓库。项目转换工作请使用本地工作台进行操作。方案基于`svn2git`工具进行操作，所以需要首先安装`svn2git`。

在安装svn2git前需要安装`svn`、`git`、`git-svn`、`ruby`和`gem`

```shell
sudo yum install svn git git-svn ruby gem
```

安装svn2git可以通过Ruby gem命令安装

```shell
sudo gem install svn2git
```

### svn authors转Git authors

如果选择在迁移时不提交authors文件进行匹配，迁移后gitlab上的提交信息的用户信息将无法正确匹配。如果不考虑这个作为问题可以忽略此步骤。如果选择匹配author，那么首选需要获取在svn仓库中所有参与到项目的author，下面的命令在将搜索svn仓库并输入author列表。

```shell
svn log --quiet | grep -E "r[0-9]+ \| .+ \|" | cut -d'|' -f2 | sed 's/ //g' | sort | uniq
```

使用输出的信息创建`authors.txt`文件，并添加逐行mapping信息

```json
weixiaohu =  weixiaohu <weixiaohu@agilesc.com>
zhujiwu = zhujiwu <zhujiwu@agilesc.com>
```

### 使用svn2git转换项目

如果svn仓库是标准格式（trunk,branches,tags,not nested）转换将非常简单，如果非标准格式可以参考[svn2git documentation](https://github.com/nirvdrum/svn2git).下面的命名将从svn中checkout项目在当前目录下进行转化，请确保在转换每个项目时都创建新的文件夹后再运行`svn2git`命令。

```shell
echo $PASSWORD | svn2git http(s)://svn.example.com/path/to/repo --authors /path/to/authors.txt --username user
```

`--authors`指定上面创建的author匹配文件，也可以忽略，`--username`用于指定checkout svn仓库时认证用户名，`$PASSWORD`表示svn用户密码。 `svn2git`命令还支持忽略branches，tags，指定文件路径等操作，详细说明可以参考[svn2git documentation](https://github.com/nirvdrum/svn2git)或运行svn2git --help命令获取完整可用选项。

### 提交本地git至远程仓库

通过svn2git命令的转换，将在本地创建一个完整的git仓库，通过`git branches`, `git tags`命令查看转换后的git仓库。

创建一个新的gitlab项目用于上传转换后的代码，拷贝仓库地址从项目主页，添加gitlab仓库作为git远程仓库并提交所有变更。下面命令将推送所有commits,branches和tags。

```shell
git remote add origin git@gitlab.com:<group>/<project>.git
git push --all origin
git push --tags origin
```

## svn2git使用期间故障处理

在使用svn2git命令时可能会报如下故障：

```shell
Use of uninitialized value $u in substitution (s///) at /usr/lib/git-core/git-svn line 1728.
Use of uninitialized value $u in concatenation (.) or string at /usr/lib/git-core/git-svn line 1728.
```

可以通过修改报错文件中指定行代码进行替换修复:

```shell
$u =~ s!^\Q$url\E(/|$)!! or die
        "$refname: '$url' not found in '$u'\n";

to this:

if(!$u) {
        $u = $pathname;
}else {
        $u =~ s!^\Q$url\E(/|$)!! or die
        "$refname: '$url' not found in '$u'\n";
}
```

或者尝试升级git和svn版本尝试修复问题。

## 参考

[Migrating from SVN to GitLab](https://docs.gitlab.com/ee/user/project/import/svn.html)

[git svn bug](https://groups.google.com/forum/#!topic/msysgit/7MQVwRO-2N4)

[svn2git](https://github.com/nirvdrum/svn2git)

[git-svn](https://git-scm.com/docs/git-svn)
