# gitlab使用规范

## 项目和组可见性

- Public：开放项目可以直接通过网址访问，所有人都可浏览项目和组下载代码
- Internal：登录gitlab系统后的用户可以访问所有Internal级别的组和项目，下载和fork项目，组内成员根据角色具备不同权限。
- Private：仅针对组内成员或者项目组内成员开放，成员根据角色具备不同权限

## 用户权限

gitlab中项目成员分为五种角色，当项目为`public`或者`internal`时候，Guest角色无效，所有用户都可以创建问题，提交评论，同步或下载项目代码。

用户在不同项目和组中根据角色不同具备不同的权限，如果在组项目和项目自身具备不同的角色，实际使用最高的权限级别。

>管理员具备最高级别权限

### 项目中权限
---

- Owner：具备项目管理的所有权限
- Master: 与Owner相比无法删除项目、更改项目名称、变更项目可见级别
- Develop: 与Master相比无法进行团队成员管理，建立保护分支、提交代码至保护分支、编辑项目及删除tags。
- Report: 与Guest相比，仅增加项目的下载、问题管理，评论状态查看功能
- Guest: 创建问题，提交评论

在Group中，仅Owner可以对组内成员进行管理，编辑和删除项目，Master用户仅可新建组内项目，其余角色都无法进行组操作。

## git中几种合并区别

1. merge:最常用，把一个分支合并到当前分支上。
2. rebase:把当前分支的提交在另一分支上重新执行。
3. cherry-pick:把分支或者其他分支的某一次或者莫几次提交，在当前分支上重演，相当于部分提交
4. patch:把一次或几次提交做成补丁文件，补丁文件可以被应用到其他分支上。

### merge vs rebase
---

1. git log区别，`merge`命令不保留merge分支的提交信息，`rebase`命名相当于重新在被合并分支执行所有提交所以会保存下所有分支。
2. 处理冲突方式
   1. `merge`处理冲突时一次性处理结束所有冲突后，执行`git add .`和`git commit -m'fix conflict'`，产生一个解决冲突提交。
   2. `rebase`采用交互方式，解决每个冲突后执行`git add .`和`git rebase --continue`，不产生额外commit.

### **merge 和 merge --no-ff的区别**
---

- 使用`merge`命令如果没有冲突，则不会产生`merge commit`
- 使用`merge --no-ff`则会强制添加一个`merge commit`

## 规范说明

- 项目和组的可见性必须选择`private`
- 项目组的创建由gitlab管理员统一建立，如需新增项目组需申请批准后添加
- 每个项目组设立一位组管理员用于组项目管理，其余项目成员的添加由各个项目自行按需添加
- 每个项目需建立三个长期分支`master`,`pre-production`,`production`,三个分支需设定为`protected branch`,同时设定仅允许`Master`角色用户合并并且不允许任何人提交至此分支
- 项目团队成员在开发时，以功能或者bug修复为前提建立临时开发分支，本地测试通过后提交`Merge Request`请求，合并通过后删除临时分支
- `pre-production`分支用于测试和试运行环境，由项目管理员负责从`master`分支中合并，并进行CI/CD操作，自动发布至测试系统环境中。
- `production`分支用于稳定发布的生产环境，当代码合并到该分支后，需建立对应tag，如有需要维护多版本系统，需同时建立发布分支

### 开发流程
![gitlab 简单开发流程](https://docs.gitlab.com/ee/workflow/github_flow.png)

开发人员在收到功能需求、bug修复等开发请求后，建立对应的开发分支进行开发，开发结束后提交合并请求至`master`分支并删除对应开发分支，这个在gitlab中可以在发起`merge request`请求时勾选在接收合并后自动删除选项自动操作。

>**在发起合并请求前需先合并最新`master`分支，避免合并冲突**

### 发布流程说明

![environment branch](https://docs.gitlab.com/ee/workflow/environment_branches.png)

上图是gitlab提供的多环境工作流说明，在此方式下`master`分支被发布到临时环境（开发内部测试）,正常后发起合并请求至`pre-production`环境，再合并至`production`环境。在这种工作流下，所有的提交都从上游向下游传递，确保所有环境中都具备完整提交。如果有bug需修复，通常在功能分支上进行开发并通过合并请求至`master`分支。在这种情况下，在没有通过测试前暂时不删除修复用的功能分支。如果`master`通过自动测试，则将功能分支合并到其他分支。如果没有自动测试还需更多手动测试，可以将修复合并至下游环境进行测试。

### 创建发布分支
![release branch](https://docs.gitlab.com/ee/workflow/release_branches.png)

如果项目对需要对外发布，可能存在多版本并行的情况（类似店销通app端或者对外发布的接口），那么需要建立对应的发布分支，发布分支命名已发布的版本号加`stable`方式命名，不包含修复版本号。发布分支建立在`production`发布时建立，在建立发布分支后仅在出现严重错误时向发布版本添加更新。在bug修复后应采用上游优先方式首先向`master`更新，在从`master`中cherry pick对应更新合并至发布分支。