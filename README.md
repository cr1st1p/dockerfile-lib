## Helper shell functions to generate Dockerfile files

Instead of writing a single, possibly big, Dockerfile, we're going to use a more developer oriented approach, that will cut on copy&paste problem (aka will be reusable), would be easier to reason about and would generate a different Dockerfile depending on if building final 'production' image or 'developer' one.

### Motivation

I don't like code repetition (copy& paste). During building various Docker images I bumped into enough of those. So I'd like to reuse whatever I can.

Also, from time to time I learn new tricks from other people's Dockerfiles - like how to install some packages  faster, or what items I can cleanup - to create smaller images. I'd like to change functionality in only one place (library), and whoever uses it, to benefit from the improvements.

Have you seen those big Dockerfile with one long RUN command that it is hard to comprehend?

Writing complex Dockerfile has 2 divergent directions regarding image size and cache use:

- if you want a smaller image then you try to have fewer layers (and include cleanup commands in the same 'RUN' command)

- but during development, you don't care about the size but you care about how fast the image gets build after changing a tiny bit of piece of code, so that you can test it. 


I would like the same code base to be able to easily handle those 2 cases. 

Using docker multi-stage builds, in order to build smaller final images is not feasible always. It would work if you would have only a few files/directories to move out from the builder image into the final image. And you're still going to have the issue with code duplication.



### Compatibility

This is a testing repository for now, and I want to improve things further. One idea is to get rid of the shell "here-doc" constructs and have real shell code. So I might break things at some point (or create another repository) - depends on the traction :-)



### For the impatient

Library files are in this directory and a sample project that installs an nginx server and puts a static html file in it, is in ```example/```

To have it run and play with it:

```shell
cd example
./build.sh --dev
cat Dockerfile # to see what it generated
docker run --rm   -p 8080:8080 cristi/dockerfile-lib-test:0.1
# in a separate terminal:
curl -v localhost:8080
# you should see some simple H1 tag with a 'Welcome'
# stop the container (Ctrl-C)
# let's see a 'production' build:
./build.sh
cat Dockerfile # and look again !
# and you can run the docker image again
```



### Details

First, we'll use functions. Good names, with a reasonable short body - you know the drill, as a developer.

To allow generating content differently in dev mode versus production, we'll use:

- a variable ```DEV_MODE``` - rarely used directly
- anytime we want to run some RUN shell commands, we're going to call first ```enter_run_cmd```
- anytime we want to run something **else** than RUN shell command, we're going to call first ```exit_run_cmd```

Those enter/exit run_cmd calls will do the appropriate splitting of RUN commands in dev mode.

Try to use ```GEN_FROM``` function call to generate the 'FROM' Dockerfile command.  It's role is to try to detect what distro you might be running inside the image, so that other scripts can take appropriate measure. Example 'nginx.sh`

Of course, you can choose to do that detection at runtime in your scripts if you want or skip it entirely. Although, personally, I prefer to always call ```run_nginx_install``` and not ```run_nginx_debian_install``` or ```run_nginx_alpine_install``` 



### Using it in  your code

One way would be to use ```git submodule``` (https://git-scm.com/book/en/v2/Git-Tools-Submodules)

#### Initial setup

```bash
cd myproject
git init # in you case you haven't done this already
git submodule add https://THIS_REPO dockerfile-lib
# you should see code being downloaded
# bring 2 files from the example directory:
cp dockerfile-lib/example/{build.sh,dockerfile-gen.sh} .
```

Now, edit the ```build.sh``` and ```dockerfile-gen.sh``` to suit your needs.

To run the build, in dev mode (i.e. use multiple RUN commands, use cached layers), run

```./build.sh --dev```

**Important:** Usually, in dev mode, the cleanup step is not called - like in the example. But you **must** also run a build in *production* mode and test it ! You might have surprises with the cleanup function removing way too much!!



#### Next git clones

```shell
git clone your_project_repo_url
cd yourproject
git submodule init
git submodule update
```



#### Writing the RUN commands

First, remember to use those *enter_run_cmd* and *exit_run_cmd* functions.

Next, for now, we're still writing the generated RUN commands as quoted multi-line shell statements...

That means, you **must**:

- start all commands with a semi-colon ```;```
- end all commands with a backslash (```\```) and NO space after it
- NO empty lines

I would use shell here-documents usually. Most of the time with the quoted separator format (a), and only when you need to use function's passed variables, the no-quote separator format (b). 

Try to minimize use of variant (b) because you must pay attention when using the dollar sign (```$```) and other quoting issues. See examples below.

(a) :

```shell
run_supervisor_setup() {    
    enter_run_cmd
    # we precreate the configuration file in here and change
    # ownership so that during start.sh we can put the appropriate
    # settings
    cat <<'EOS'
    ; mkdir -p /var/www \
    ; touch /var/www/supervisord.conf \
    ; touch /var/www/supervisord.pid \
    ; chown nginx:nginx /var/www/supervisord.* \
EOS
}
```

(b):

```shell
run_git_clone_into_existing_dir() {
    local url="$1"
    local dest="$2"
    shift 2
    # rest of parameters are given to git checkout

    enter_run_cmd

    cat <<EOS
    ; ld=\$(pwd) \\
    ; cd "$dest" \\
    ; git clone "$url" "existing-dir.tmp" \\
    ; mv 'existing-dir.tmp/.git' "." \\
    ; rm -rf "existing-dir.tmp/" \\
    ; git reset --hard HEAD \\
    ; git checkout $@ \\
EOS

}
```

### Writing reusable functions

I there is a slight chance that you might reuse some of your functions in a future project, I would recommend you create a separate directory with those shell functions in it.

In this way, later, you could get your project as well as a git submodule dependency, and re-use those functions.

