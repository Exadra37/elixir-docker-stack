# CREATE BRANCHES

Depending on the type of issue the branch for it will have a different origin.


## BUG FIX / SECURITY FIX

As per [Issues Guidelines](docs/how-to/create_an_issue.md) we do not need to have a Milestone for it.

Considering that we have issue number `4` with title `Fix Email Validation`.

```bash
git fetch && git checkout -b issue-4_fix-email-validation origin/master
```


## NEW FEATURE / IMPROVE FEATURE / REFRACTING CODE

As per [Issues Guidelines](docs/how-to/create_an_issue.md) we must have a Milestone for this type of requirement.

Once the Milestone can be split in several issues, lets imagine:

* Milestone number `12` with title `Add Cache`.
* Issue number `14` with title `Create Cache Interfaces`.
* Issue number `15` with title `Implement Redis Cache`.
* Issue number `16` with title `Implement File System Cache`.


#### Creating Milestone Branch:

```bash
git fetch && git checkout -b milestone-12_add-cache origin/master && git push origin milestone-12_add-cache
```

#### Creating Issues Branches:

```bash
git fetch && git checkout -b issue-14_create-cache-interfaces origin/milestone-12_add-cache
```

```bash
git fetch && git checkout -b issue-15_implement-redis-cache` origin/milestone-12_add-cache
```

```bash
git fetch && git checkout -b issue-16_implement-file-system-cache` origin/milestone-12_add-cache
```


---

[<< previous](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/how-to/create_an_issue.md) | [next >>](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/docs/how-to/create_a_merge_request.md)

[HOME](https://gitlab.com/exadra37-docker/elixir/elixir/blob/master/README.md)
