locals {
  tracked_files = setunion(
    fileset(local.git_repo_root, "src/*"),
    fileset(local.git_repo_root, "{Pipfile,Pipfile.lock}"),
  )
  dir_sha1 = sha1(join("",
    [for f in local.tracked_files : filesha1("${local.git_repo_root}/${f}")]
  ))
  tagged_image_name = "${local.base_name}:${local.dir_sha1}"

}

# build image locally
resource "docker_image" "this" {
  name = local.base_name
  build {
    context    = local.git_repo_root
    dockerfile = "${local.git_repo_root}/docker/Dockerfile"
    tag        = [local.tagged_image_name]
  }

  # rebuild the docker image only if application files have changed
  triggers = {
    dir_sha1 = local.dir_sha1
  }
}


