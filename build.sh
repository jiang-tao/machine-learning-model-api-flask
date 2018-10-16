#!/bin/bash

function help {
    echo "Display this help:
                build.sh --help
            "
    echo "Interactive Build:
                build.sh
            "
    echo "Automated Build for CI/CD pipelines: 
                build.sh --model <model_name>
                    [-d|--desc <desc>]
                    -v|--version <model_version> 
                    -r|--repo <git_repo> 
                    -b|--branch <git_branch> 
                    -s|--script <python_serving_script>
                    -f|--function <python_serving_function>
                    [-p|--package <model_package>]
                    [--package-secret <model_package_secret>]
            "
    exit 0
}

function parse_param {
    while :
    do
        case "$1" in
        -h | --help)
        help  # Call help function
                # no shifting needed here, we're done.
        exit 0
        ;;
        --model)
            ML_MODEL_NAME="$2"
            shift 2
            ;;
        -d | --desc)
            ML_MODEL_DESC="$2"
            shift 2
            ;;
        -v | --version)
            ML_MODEL_VERSION="$2"
            shift 2
            ;;
        -r | --repo )
            ML_REPO="$2"
            shift 2
            ;;
        -b | --branch )
            ML_REPO_BRANCH="$2"
            shift 2
            ;;
        -s | --script )
            ML_API_SCRIPT="$2"
            shift 2
            ;;
        -f | --function )
            ML_SCORING_FUNC="$2"
            shift 2
            ;;
        -p | --package )
            ML_PACKAGE="$2"
            shift 2
            ;;
        --package-secret )
            ML_PACKAGE_SECRET="$2"
            shift 2
            ;;
        --) # End of all options
        shift
        break;
            ;;
        -*)
        echo "Error: Unknown option: $1" >&2
        exit 1
        ;;
        *)  # No more options
        break
        ;;
        esac
    done
}

function set_var {
    VAR_NAME="$1";
    VAR_DEFAULT="$2"
    VAR_VALUE="$3";
    if [[ -z "$VAR_VALUE" ]]; then
        read -s -p "Please key in \"$VAR_NAME\" ($VAR_DEFAULT):" VAR_VALUE;
        if [[ -z "$VAR_VALUE" ]]; then
            VAR_VALUE="$VAR_DEFAULT"
        fi
        echo ""
    fi
    export ${VAR_NAME}=${VAR_VALUE}
}

function check_var {
    set_var ML_MODEL_NAME "salary_lr_model" $ML_MODEL_NAME
    set_var ML_MODEL_DESC "A LR model to predict salary" $ML_MODEL_DESC
    set_var ML_MODEL_VERSION "1.0" $ML_MODEL_VERSION
    set_var ML_REPO "./apiserver/model" $ML_REPO
    set_var ML_REPO_BRANCH "" $ML_REPO_BRANCH
    set_var ML_API_SCRIPT "salary_lr_model" $ML_API_SCRIPT
    set_var ML_SCORING_FUNC "score" $ML_SCORING_FUNC
    set_var ML_PACKAGE "" $ML_PACKAGE
    set_var ML_PACKAGE_SECRET "" $ML_PACKAGE_SECRET

    echo "## ML_MODEL_NAME: $ML_MODEL_NAME"
    echo "## ML_MODEL_DESC: $ML_MODEL_DESC"
    echo "## ML_MODEL_VERSION: $ML_MODEL_VERSION"
    echo "## ML_REPO: $ML_REPO"
    echo "## ML_REPO_BRANCH: $ML_REPO_BRANCH"
    echo "## ML_API_SCRIPT: $ML_API_SCRIPT"
    echo "## ML_SCORING_FUNC: $ML_SCORING_FUNC"
    echo "## ML_PACKAGE: $ML_PACKAGE"
}

function model_build {
    ML_REPO="$1"
    ML_REPO_BRANCH="$2"
    ML_PACKAGE="$3"
    ML_PACKAGE_SECRET="$4"

    echo "model_build: "
    echo "## ML_REPO: $ML_REPO"
    echo "## ML_REPO_BRANCH: $ML_REPO_BRANCH"
    echo "## ML_PACKAGE: $ML_PACKAGE"

    [ -d ./target ] && rm -rf ./target
    CURDIR=$(pwd) && \
    mkdir -p ./target && \
    cp -r ./apiserver ./target/ && \
    [[ -d ./target/apiserver/model ]] && rm -rf ./target/apiserver/model

    #if git repo, do git clone; otherwise, copy dir
    if [[ $ML_REPO == http* ]] || [[ $ML_REPO == ssh* ]]; then
        git clone -b ${ML_REPO_BRANCH} ${ML_REPO} ./target/apiserver/model
    else
        [[ $ML_REPO == .* ]] && cp -r "${CURDIR}/${ML_REPO}" ./target/apiserver/model
        [[ $ML_REPO == /* ]] && cp -r "${ML_REPO}" ./target/apiserver/model
    fi
    echo "" >> ./target/apiserver/model/__init__.py #ensure the model init script exists

    #Download ML_PACKAGE
    cd ./target/apiserver/model/
    if [[ $ML_PACKAGE == http* ]]; then
        curl -O ${ML_PACKAGE}
    else
        [[ $ML_PACKAGE == .* ]] && cp "${CURDIR}/${ML_PACKAGE}" ./
        [[ $ML_PACKAGE == /* ]] && cp "${ML_PACKAGE}" ./
    fi
    
    # rm -f $(basename $ML_PACKAGE)
    cd $CURDIR

    echo "Done."
}


parse_param $@ 

check_var

model_build "${ML_REPO}" "${ML_REPO_BRANCH}" "${ML_PACKAGE}" "${ML_PACKAGE_SECRET}"

docker build --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy \
    --build-arg no_proxy=$no_proxy \
    --build-arg ML_MODEL_NAME="${ML_MODEL_NAME}" \
    --build-arg ML_MODEL_DESC="${ML_MODEL_DESC}" \
    --build-arg ML_MODEL_VERSION="${ML_MODEL_VERSION}" \
    --build-arg ML_API_SCRIPT="${ML_API_SCRIPT}" \
    --build-arg ML_SCORING_FUNC="${ML_SCORING_FUNC}" \
    --build-arg ML_PACKAGE="${ML_PACKAGE}" \
    --build-arg ML_PACKAGE_SECRET="${ML_PACKAGE_SECRET}" \
    -t ${ML_MODEL_NAME}:${ML_MODEL_VERSION} .

