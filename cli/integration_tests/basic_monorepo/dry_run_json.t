Setup
  $ . ${TESTDIR}/../setup.sh
  $ . ${TESTDIR}/setup.sh $(pwd)

# Save JSON to tmp file so we don't need to keep re-running the build
  $ ${TURBO} run build --dry=json > tmpjson.log

# test with a regex that captures what release we usually have (1.x.y or 1.a.b-canary.c)
  $ cat tmpjson.log | jq .turboVersion
  "\d\.\d\.\d(-canary\.\d)?" (re)

  $ cat tmpjson.log | jq .globalHashSummary
  {
    "globalFileHashMap": {
      "foo.txt": "eebae5f3ca7b5831e429e947b7d61edd0de69236"
    },
    "rootExternalDepsHash": "ccab0b28617f1f56",
    "globalCacheKey": "Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo",
    "pipeline": {
      "build": {
        "outputs": [],
        "cache": true,
        "dependsOn": [],
        "inputs": [],
        "outputMode": "full",
        "env": [
          "NODE_ENV"
        ],
        "persistent": false
      },
      "my-app#build": {
        "outputs": [
          "apple.json",
          "banana.txt"
        ],
        "cache": true,
        "dependsOn": [],
        "inputs": [],
        "outputMode": "full",
        "env": [],
        "persistent": false
      }
    }
  }

# Validate output of my-app#build task
  $ cat tmpjson.log | jq '.tasks | map(select(.taskId == "my-app#build")) | .[0]'
  {
    "taskId": "my-app#build",
    "task": "build",
    "package": "my-app",
    "hash": "e8ca4fc486de5b37",
    "cacheState": {
      "local": false,
      "remote": false
    },
    "command": "echo 'building'",
    "outputs": [
      "apple.json",
      "banana.txt"
    ],
    "excludedOutputs": null,
    "logFile": "apps/my-app/.turbo/turbo-build.log",
    "directory": "apps/my-app",
    "dependencies": [],
    "dependents": [],
    "resolvedTaskDefinition": {
      "outputs": [
        "apple.json",
        "banana.txt"
      ],
      "cache": true,
      "dependsOn": [],
      "inputs": [],
      "outputMode": "full",
      "env": [],
      "persistent": false
    },
    "expandedInputs": {
      "package.json": "f2a5d2525f3996a57680180a7cd9ad7310e4dec0"
    },
    "expandedOutputs": [],
    "framework": "<NO FRAMEWORK DETECTED>",
    "environmentVariables": {
      "configured": [],
      "inferred": [],
      "global": [
        "SOME_ENV_VAR=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "VERCEL_ANALYTICS_ID=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
      ]
    }
  }

# Validate output of util#build task
  $ cat tmpjson.log | jq '.tasks | map(select(.taskId == "util#build")) | .[0]'
  {
    "taskId": "util#build",
    "task": "build",
    "package": "util",
    "hash": "1a3651e1149bfaf7",
    "cacheState": {
      "local": false,
      "remote": false
    },
    "command": "echo 'building'",
    "outputs": null,
    "excludedOutputs": null,
    "logFile": "packages/util/.turbo/turbo-build.log",
    "directory": "packages/util",
    "dependencies": [],
    "dependents": [],
    "resolvedTaskDefinition": {
      "outputs": [],
      "cache": true,
      "dependsOn": [],
      "inputs": [],
      "outputMode": "full",
      "env": [
        "NODE_ENV"
      ],
      "persistent": false
    },
    "expandedInputs": {
      "package.json": "8d3e121335e16dbd8d99c03522b892ec52416dda"
    },
    "expandedOutputs": [],
    "framework": "<NO FRAMEWORK DETECTED>",
    "environmentVariables": {
      "configured": [
        "NODE_ENV=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
      ],
      "inferred": [],
      "global": [
        "SOME_ENV_VAR=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "VERCEL_ANALYTICS_ID=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
      ]
    }
  }

Run again with NODE_ENV set and see the value in the summary. --filter=util workspace so the output is smaller
  $ NODE_ENV=banana ${TURBO} run build --dry=json --filter=util | jq '.tasks | map(select(.taskId == "util#build")) | .[0].environmentVariables'
  {
    "configured": [
      "NODE_ENV=b493d48364afe44d11c0165cf470a4164d1e2609911ef998be868d46ade3de4e"
    ],
    "inferred": [],
    "global": [
      "SOME_ENV_VAR=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "VERCEL_ANALYTICS_ID=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    ]
  }

Tasks that don't exist throw an error
  $ ${TURBO} run doesnotexist --dry=json
   ERROR  run failed: error preparing engine: Could not find the following tasks in project: doesnotexist
  Turbo error: error preparing engine: Could not find the following tasks in project: doesnotexist
  [1]
