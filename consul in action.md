# Consul 使用说明

## KV Store Endpoints

### **Read key**

>GET  /kv/:key  

**Parameter:**

- `key`(string: "") - Specifies the path of key to read.
- `dc`(string: "") - Specifies the datacenter to query. This will default to the datacenter of the agent being queried.
- `recurse`(bool: false) - Specifies if lookup should be recursive and key treated as a prefix instead of a literal match.
- `raw`(bool: false) - Specifies the reponse is just the raw value of the key, without any encoding or metadata.
- `keys`(bool: false) - Specifies the return only keys(no value or metadata).Specifying this implies `recurse`.
- `separator`(string: '/') - Specifies the string to use as a separator for recursive key lookups. This option is only used whenn paired with the `keys` parameter to limit the prifix of keys returned, only up to the given spearator. If the key not container the separator also will be returned.

### **Simple request**

```shell
$ curl \
    http://localhost:8500/v1/kv/my-key
```

### **Simple response**

```json
[
  {
    "CreateIndex": 100,
    "ModifyIndex": 200,
    "LockIndex": 200,
    "Key": "zip",
    "Flags": 0,
    "Value": "dGVzdA==",
    "Session": "adf4238a-882b-9ddc-4a9d-5b6758e4159e"
  }
]
```

- `CreateIndex` is the internal index value that represents when the entry was created.
- `ModifyIndex` is the last index that modified this key. This index corresponds to the `X-Consul-Index` header value that is returned in reponses, and it can bi used to establish blocking queries by setting the ?index querey paramter.
- `LockIndex` is the number of times this key has successfully been acquired in a lock. If the lock is held, the Session key provides the session that owns the lock.
- `Key` is simply the full path of the entry.
- `Flags` is an opaque unsigned integer that can be attached to each entry. Clients can choose to use this however makes sense for their application.
- `Value` is a base64-encoded blob of data.

#### Keys Response

使用`?key`参数后，返回结果为一个Json字符串数组，包含所有符合条件的key

```shell
[
  "/web/bar",
  "/web/foo",
  "/web/subdir/"
]
```

### Creat/Update Key

| Method | Path | Produces|
|:----|:----|:-----|
|PUT|/kv/:key|application/json|

虽然显示返回类型为`application/json`,实际值为`true`or`false`。

**Parameter:**

- `key`(string: "") - Specifies the path of the key to read
- `dc`(String: "") - Specifies the datacenter to query. like read key defined.
- `flags`(int: 0) - Specifies an unsigned value between 0 and (2^64)-1.Client can choose to use this however makes sense for their appliction.
- `cas`(int:0) - Specifies to use a Check-And-Set operation, This is very useful as a building block for more complex synchronization primitives. If the index is 0, Consul will only put the key if it dose not already exist. If the index is non-zero,the key is only set if the index matches the ModifyIndex of that key.
- `acquire`(string: "") - Specifies to use a lock acquisition operation. This is useful as it allows leader election to be built on top of Consul.If the lock is not held and the session is valid, this increments the LockIndex and set the Session value of the key in addition to updating the key contents. A key does not need to existe to be acquired. If the lock is already held by the given session, then the Lockindex is not incremented but the key contents are updated. This lets the current lock holder update the key contents without having to give up the lock and reaquire it .**Note that an update that does not include the acquire parameter will proceed normally even if another session has locked the key.**
- `release`(string: "") - Specifies to use a lock release operation. This is useful when paired with ?acquire= as it allows clients to yield a lock. This will leave the LockIndex unmodified but will clear the associated Session of the key.The key must be held by this session to be unlocked.

#### Simple Payload

  上传的内容都可以是任意内容，并被直接加载用于Consul.

#### Sample Requests

```shell
$ curl \
    --request PUT \
    --data @contents \
    http://127.0.0.1:8500/v1/kv/my-key

# or

$ curl \
    --request PUT \
    --data-binary @contents \
    http://127.0.0.1:8500/v1/kv/my-key
```

#### Sample Response

```shell
true
```

### Delete Key

该endpoint删除单个键或者指定前缀下所有键

|Method|Path|Produces|
|:---|:---|:---|
|DELETE|/kv/:key|application/json|

#### **Parameters**

- `recurse`(bool: false) - Specifies to delete all keys which have the specified prefix. Without this, only a key with an exact match will be deleted.
- `cas`(int: 0) - Specifies to use a Check-And-Set operation. This is very useful as a building block for more complex synchronization primitives. Unlike PUT, the index must be greater than 0 for Consul to take any action: a 0 index will not delete the key. If the index is non-zero, the key is only deleted if the index matches the ModifyIndex of that key.

#### Simple Request

```shell
$ curl \
    --request DELETE \
    http://127.0.0.1:8500/v1/kv/my-key
```

#### Simple Response

```json
true
```