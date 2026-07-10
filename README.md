# KEcoLab

Welcome to the KEcoLab GitLab repository! This project enables you to measure energy consumption of your software remotely using a CI/CD pipeline. Follow the steps below to get started.

## Table of Contents

 - [Introduction](#introduction)
 - [Getting Started](#getting-started)
   - [Prerequisites](#prerequisites)
   - [Required Formats](#required-formats)
 - [Usage](#usage)
   - [Merge Requests](#merge-requests)
   - [CI/CD Pipeline](#ci/cd-pipeline)
   - [Results](#results)
 - [Contribute](#contribute)
   - [KEcoLab Development](#kecoLab-development)
   - [MRs Without Automated Pipeline](#mrs-without-automated-pipeline)
   - [Communication](#communication)
   

## Introduction 

KEcoLab aims to provide a streamlined process for measuring software energy consumption remotely using a CI/CD pipeline. By automating the measurement process and integrating the [OSCAR](https://gitlab.rlp.net/green-software-engineering/oscar) (Open-source Software Consumption Analysis in R) tool, developers can make data-driven decisions to improve code efficiency and obtain software eco-certification with the [Blue Angel](https://www.blauer-engel.de/en/productworld/software).

For further details on measuring the energy consumption of software, please refer to: [eco.kde.org/be4foss-handbook](https://eco.kde.org/be4foss-handbook/)

## Getting Started

This will help you get started with measuring your software's energy consumption.

If you have any trouble while performing the steps below, refer to this tutorial video for help: 

![KEcolab-Tutorial](KEcolab-Tutorial.mp4) 

### Prerequisites

Ensure you have the following prerequisites in place:

 - Flatpak application ID (e.g., for [Okular](https://flathub.org/en/apps/org.kde.okular) this is `org.kde.okular`);
 - Three usage scenario scripts (Standard Usage Scenario, Idle Scenario, Baseline Scenario). To create these scripts, follow the guidelines provided in [How to measure your software](https://eco.kde.org/be4foss-handbook/#a-how-to-measure-your-software). Various tools, such as [KDU GUI Test](https://invent.kde.org/sdk/kde-gui-test), [ydotool/kdotool](https://planet.kde.org/hrishikesh-gohain-2026-02-06-write-standard-user-scenerio-scripts-to-measure-energy-usage-of-software-with-kecolab/), etc. can be used for script creation;
 - Basic Git knowledge.

Note: In case you need to add any external files required for testing of your software, you can put them at this location `scripts/test_scripts/<FLATPAK_APPLICATION_ID>/`. These files will be saved in the `/tmp/` directory on the KEcolab system.

### Required Formats

Note: Ensure filenames match exactly as specified below, and the output adheres precisely to the given examples. Any deviations will result in the pipeline failing at either the `energy_measurement` or `result` stage.

 - Ensure your input scripts adhere to the following format:
   - Standard Usage Scenario filename: `log_sus.sh`. 
     - For output to be imported into OSCAR, the required format is `iteration no;yy-mm-dd hh:mm:ss;startAction;<ACTION>`. The sequence must be: startTestrun, startAction, stopAction, and then stopTestrun. Example of Standard Usage Scenario output:
     ```
     iteration 1;2026-06-24 11:15:44;startTestrun
     iteration 1;2026-06-24 11:15:45;startAction;Open PDF document 
     iteration 1;2026-06-24 11:15:47;stopAction
     […]
     iteration 1;2026-06-24 11:19:23;stopTestrun
     ```
   - Idle Scenario filename: `log_idle.sh`:
     - For output to be imported into OSCAR, the required format is `iteration no;yy-mm-dd hh:mm:ss;startAction;<ACTION>`. Example of Idle Scenario output:
     ```
     iteration 1;2026-06-24 14:42:27;startTestrun
     iteration 1;2026-06-24 14:42:28;startAction;open okular
     iteration 1;2026-06-24 14:42:29;stopAction
     iteration 1;2026-06-24 14:46:05;startAction;Quit Okular 
     iteration 1;2026-06-24 14:46:06;stopAction 
     iteration 1;2026-06-24 14:46:06;stopTestrun
     ```
   - Baseline Scenario filename: `log_baseline.sh`:
     - For output to be imported into OSCAR, the required format is `iteration no;yy-mm-dd hh:mm:ss;startTestrun`. Example of Baseline Scenario output:
     ```
     iteration 1;2026-06-24 13:50:45;startTestrun
     iteration 1;2026-06-24 13:54:24;stopTestrun
     ``` 

For example output, see [here](https://invent.kde.org/teams/eco/feep/-/blob/master/measurements/okular/2026-06-24/2024-06-24_artifacts_data.zip).

## Usage

First, prepare the three usage scenario scripts on your system. See [here](https://invent.kde.org/sdk/kecolab/-/tree/master/scripts/test_scripts/org.kde.okular) for examples with Okular.

### Merge Requests

Once the scripts are ready.

 - Fork or clone the KEcoLab repository to your Invent account.
 - Create a new branch in your fork and add the usage scenario scripts in the path `scripts/test_scripts/<FLATPAK_APPLICATION_ID>` (for example, `scripts/test_scripts/org.kde.okular/log_sus.sh`).
 - Push the changes and initiate a merge request, using the Flatpak application ID as the title. For example, `org.kde.okular`.

### CI/CD Pipeline

 - The CI/CD pipeline will be triggered automatically. The pipeline has the following three stages:
   - 1. **build**: In this stage, the Flatpak version of the app is installed.
   - 2. **energy_measurement**: This stage focuses on remote energy consumption measurement, involving interactions with the lab PC, [Gude power meter](https://gude-systems.com/app/uploads/2022/05/manual-epc1202-series.pdf), and Raspberry PI. The scripts are run while readings from the power meter and hardware data are collected using the [`collectl`](https://sourceforge.net/projects/collectl/) tool and a [Gude Python script](https://invent.kde.org/teams/eco/feep/-/tree/master/tools/GUDEPowerMeter), respectively. These are available as artifacts from this stage.
   - 3. **result**: The energy measurement results obtained are used as input for the OSCAR analysis script. OSCAR generates a report file summarizing energy consumption measurements and provides visualizations, also available as an artifact.

### Results

 - Energy measurement artifacts can be found at [Job Artifacts](https://invent.kde.org/sdk/kecolab/-/artifacts) under the `energy_measurement` stage.
 - The final Energy measurement report is also available at [Job Artifacts](https://invent.kde.org/sdk/kecolab/-/artifacts) under the `result` stage.
 - Utilize the reports to analyze energy consumption during various actions and leverage this information to enhance your application's energy efficiency or to pursue eco-certification with the [Blue Angel ecolabel](https://www.blauer-engel.de/en/productworld/software).


## Contribute

### KEcoLab Development

KEcoLab is in continuous development. For open work items: <https://invent.kde.org/sdk/kecolab/-/work_items>

### MRs Without Automated Pipeline

When working on features, fixes, and other changes to KEcoLab, you may need to make a Merge Request but do not want the measurement pipeline to run automatically. In this case, add `dev:` at the beginning of your Merge Request title and the CI/CD pipeline will be skipped.

### Communication

For discussions about KEcoLab, including updates, technical discussions, bug reporting, and general feedback, connect with the team on [Matrix](https://community.kde.org/Matrix): [#kde-eco-dev:kde.org](https://matrix.to/#/#kde-eco-dev:kde.org).

For other ways to get involved with KDE Eco: https://eco.kde.org/get-involved/
