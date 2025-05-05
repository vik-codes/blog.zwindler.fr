---
title: Run AIDungeon 2 on Ubuntu 18.04
authors:
  - zwindler
type: post
date: 2020-01-08T11:30:00+00:00
excerpt: Step by step tutorial to self host AIDungeon 2 locally on a Ubuntu 18.04 server with a big GPU card
url: /2020/01/08/run-aidungeon-2-on-ubuntu-18-04/
image: /2020/01/aidungeon_screen.png
categories:
  - autohebergement
  - DIY
  - materiel
tags:
  - AIDungeon
  - AIDungeon 2
  - GPU
  - GTX
  - Machine Learning
  - OpenAI
  - tegra

---

## AIDungeon 2
  
  
A few weeks ago, I stumbled upon AIDungeon 2, a hilarious project mixing _Text based_ adventure, (heavy) machine learning and big (big BIG) CUDA GPUs.


> AIDungeon2 is a first of its kind AI generated text adventure. Using a 1.5B parameter machine learning model called GPT-2 AIDungeon2 generates the story and results of your actions as you play in this virtual world. Unlike virtually every other game in existence, you are not limited by the imagination of the developer in what you can do. Any thing you can express in language can be your action and the AI dungeon master will decide how the world responds to your actions.
> https://www.aidungeon.io/


So, if you haven’t heard of it yet, it’s a machine learning project created by Nick Walton, a college student. It’s based on the [GPT-2 text model from OpenAI](https://openai.com/blog/better-language-models/) that you may already seen in other fun projects and was trained to predict the next word using 40 GB of Internet text (you can also check [TalkTotransformer by Adam D King](https://talktotransformer.com/)).



## So... What does it do ?
  
  
That’s where the fun begins. Like the TalkTotransformer generator, from a simple semi random generated background, the machine learning model builds the start of a new story, different every time. And your actions stear the story in one way or the other.

I won’t lie, it’s far from perfect. The model tends to run in circles, or forgets what the other characters did just a line before, which can be really annoying.

But... aside from this, the possibilities seem to be limitless, and that’s REALLY impressive.

After all, that’s not really surprising. You’re only limited by the knowledge and writing style of 40 GB of Internet text! If you need examples, I invite you to take a look at Nick Walton’s twitter feed or [AIDungeon subreddit](https://www.reddit.com/r/AIDungeon/) to find out the most hilarious adventures the AIDungeon community came upon.



![](/2020/01/story.png) 

> In this example, my inputs are the 2 lines preceded by the « > » symbol, the machine did the rest 

## What’s the catch ?
  
I’ve already said it.

That game is probably _the most GPU intensive game you’ve run in your life_. For a text based adventure, even that is already ironically fun.

The game requires nearly 9 GB of GPU VRAM and a lot of CUDA cores, ruling out all AMD cards and nearly every NVidia cards costing less than 1500$.

Bummer...


## Community to the rescue

Hopefully, the community enthusiasm was so intense that Nick Walton and his brother have decided to drop everything else to improve it. During december, they built mobile Apps and now a web based one to play on every device.

Of course, these apps run on AWS servers featuring Tegra GPUs and cost around 65k$ a month in hosting. They have managed to raise nearly 15k$/month on their Patreon Account but there may come a day (probably very soon) where they won’t be able to provide free access for everyone.

So, after you read the article, [if you like the game, don’t forget to support them!](https://www.patreon.com/AIDungeon)

## So what now?
  
It also turns out that, Nick Walton published the game as an open source project. That’s where I became the most interested in this game, in fact. And you can find the sources [on the Github AIDungeons project](https://github.com/AIDungeon/AIDungeon).

Starting from there, I asked myself:


> Hey! Wouldn’t it be nice to run it on a cloud instance on a random cloud provider GPU powered VM?


So I decided to try it.

For my test, I chose to run AIDungeon on a NC6 virtual machine (6 vcpus, 56 GiB memory, Tegra K80) on Microsoft Azure on a free test account. This machine costs approximatly 0.43€ per hour (or even 0,21€ if you use preemtible VMs) so even if you don’t use a free credit, it won’t cost you too much.

Side note: Of course, if you have a GTX 1080 Ti, GTX 2080 Ti or GTX 2080ti super (or a K80), you can also run it on your own machine...

On my NC6, I deployed a Ubuntu 18.04.

And that’s where this tutorial begins ;-)



![](/2020/01/aidungeon.png) 


Side note: If you follow this guide and start on a fresh Ubuntu 18.04, the installation process should take 30 minutes to 45 minutes.



## Install updates and prerequisites
  
  
Once connected on the machine, update and upgrade the OS.

```
sudo apt-get update
sudo apt-get upgrade
```

Then, install prerequisites packages for AI

```
sudo apt-get install git aria2 unzip python3-pip
```

## Dependancy hellscape
  
Now, the real fun begins. AIDungeon uses TensorFlow and CUDA drivers to run. But here’s the catch: not every versions will work!

To run AIDungeons, you have to install specifically tensorflow 1.15 (no more, no less). And tensorflow==1.15 specifically requires cuda10.0 (not cuda10.1 nor cuda10.2) and Python 3.4 to 3.7!

The dependancy nightmare begins...

## Install NVidia drivers and Cuda and machine learning modules
  
  
Add the cuda10.0 repos:


```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo apt-get update

wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
sudo apt install ./nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
sudo apt-get update
```



Now, we can install nvidia-driver, and reboot:


```
sudo apt-get install --no-install-recommends nvidia-driver-440 xserver-xorg-video-nvidia-440
sudo reboot
```



After reboot, install cuda10.0 libs


```
sudo apt-get install --no-install-recommends \
    cuda-10-0 cuda-runtime-10-0 cuda-demo-suite-10-0 cuda-drivers \
    libcudnn7=7.6.2.24-1+cuda10.0 libcudnn7-dev=7.6.2.24-1+cuda10.0

sudo apt-get install -y --no-install-recommends libnvinfer5=5.1.5-1+cuda10.0 \
    libnvinfer-dev=5.1.5-1+cuda10.0
```



## Get the sources
  
  
Download the source from Github and hop-in in the directory:


```
git clone https://github.com/AIDungeon/AIDungeon/
cd AIDungeon/
```



## Install python dependancies through pip
  
  
Sadly, installation time not yet over. Now that we have the python project on deck, we need to install the Python dependancies... By default, Ubuntu 18.04 still serves Python 2 as default Python interpreter, which is now deprecated since 1st january. Hopefully Python 3 is easily available (not like on CentOS 7).

Also, the pip (python package manager) installed should be updated as pip installed by Ubuntu is not compatible with tensorflow 1.15.

Upgrading pip in place can be tedious as this often lead to "pip ImportError: cannot import name &lsquo;main’ after update" error message. To work around this, use the script given in [upgrading pip](https://pip.pypa.io/en/stable/installing/#upgrading-pip) official page and you should be fine.


```
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py
```



## Install AIDungeon for good
  
  
Since I wrote the draft of the article a few weeks ago, there was a dependancy missing (gsutil) and the install script was not perfect. But now it seems to be working better and even uses venvs for a clean Python dependancies install.


```
sudo ./install.sh
```



If it doesn’t work, you can install it yourself with the following commands:


```
python3 -m pip install -r requirements.txt --user
```



The next script allows you to download the AIDungeon machine learning model through a torrent file (at first, Nick had a terrifying GDrive bill due to enormous egress traffic).


```
./download_model.sh
[...]
Status Legend:
(OK):download completed.
Download Complete!
```



## Run AIDungeon 2
  
  
Finally, you can now sit back and enjoy the game!

If you used the install.sh script, use the following command (with venv):


```
source ./venv/bin/activate
./play.py
```



If not, skip the venv step:


```
cd ~/AIDungeon/
python3 play.py
```



![](/2020/01/initializing.png) 


The initialisation should take a few minutes (don’t panic, it’s "normal"), depending of your setup. In december, initialization took 5-10 minutes but there seem to have been optimisation now as it took only a minute or two last time I checked.



![](/2020/01/aidungeon_screen.png) 


## Bonus: Useful command to check GPU consumption
  
  
Install gpustat to check if GPU usage is working


```
pip3 install gpustat --user
gpustat
gpustat -cp
aidungeon2           Mon Dec  9 13:22:24 2019  430.50
[0] Tesla K80        | 69'C,  17 % |     0 / 11441 MB |
```



Or use integrated nvidia tool (a little crude)


```
nvidia-smi --loop=1
```



## Bonus: Check that GPU is working with tensorflow
  
  
See [Tensorflow GPU guide](https://www.tensorflow.org/guide/gpu)


```
python3

from __future__ import absolute_import, division, print_function, unicode_literals
import tensorflow as tf

print("Num GPUs Available: ", len(tf.config.experimental.list_physical_devices('GPU')))
```

Example working GPU setup

```
2019-12-10 16:25:39.714605: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcuda.so.1
2019-12-10 16:25:39.743758: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1618] Found device 0 with properties: 
name: Tesla K80 major: 3 minor: 7 memoryClockRate(GHz): 0.8235
pciBusID: 81c7:00:00.0
2019-12-10 16:25:39.744001: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudart.so.10.0
[...]
2019-12-10 16:25:39.754396: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1746] Adding visible gpu devices: 0
Num GPUs Available:  1
```



Example of non working GPU setup

```
[...]
Num GPUs Available:  0
```



If you have this, game will be very slow (waiting 1-2 minutes between each answer) but will not crash. Check that Cuda and tensorFlow are proprely installed.


## Bonus: gsutil and tensorflow errors
  
  
If you forgot or failed to upgrade pip, you will get this error :


```
Collecting tensorflow==1.15 (from -r requirements.txt (line 6))
  Could not find a version that satisfies the requirement tensorflow==1.15 (from -r requirements.txt (line 6)) (from versions: 0.12.1, 1.0.0, 1.0.1, 1.1.0rc0, 1.1.0rc1, 1.1.0rc2, 1.1.0, 1.2.0rc0, 1.2.0rc1, 1.2.0rc2, 1.2.0, 1.2.1, 1.3.0rc0, 1.3.0rc1, 1.3.0rc2, 1.3.0, 1.4.0rc0, 1.4.0rc1, 1.4.0, 1.4.1, 1.5.0rc0, 1.5.0rc1, 1.5.0, 1.5.1, 1.6.0rc0, 1.6.0rc1, 1.6.0, 1.7.0rc0, 1.7.0rc1, 1.7.0, 1.7.1, 1.8.0rc0, 1.8.0rc1, 1.8.0, 1.9.0rc0, 1.9.0rc1, 1.9.0rc2, 1.9.0, 1.10.0rc0, 1.10.0rc1, 1.10.0, 1.10.1, 1.11.0rc0, 1.11.0rc1, 1.11.0rc2, 1.11.0, 1.12.0rc0, 1.12.0rc1, 1.12.0rc2, 1.12.0, 1.12.2, 1.12.3, 1.13.0rc0, 1.13.0rc1, 1.13.0rc2, 1.13.1, 1.13.2, 1.14.0rc0, 1.14.0rc1, 1.14.0, 2.0.0a0, 2.0.0b0, 2.0.0b1)
No matching distribution found for tensorflow==1.15 (from -r requirements.txt (line 6))
```



You should not come across this anymore now, but if you get this error you should install gsutil python module to avoid stacktrace when saving / exiting


```
> ^C
Traceback (most recent call last):
  File "play.py", line 211, in <module>
    play_aidungeon_2()
  File "play.py", line 97, in play_aidungeon_2
    action = input("> ")
KeyboardInterrupt
Exception ignored in: <bound method Story.__del__ of <story.story_manager.Story object at 0x7f797f4af0f0>>
Traceback (most recent call last):
  File "/home/zwindler/AIDungeon/story/story_manager.py", line 35, in __del__
    self.save_to_storage()
  File "/home/zwindler/AIDungeon/story/story_manager.py", line 131, in save_to_storage
    p = Popen(['gsutil', 'cp', file_name, 'gs://aidungeonstories'], stdout=FNULL, stderr=subprocess.STDOUT)
  File "/usr/lib/python3.6/subprocess.py", line 729, in __init__
    restore_signals, start_new_session)
  File "/usr/lib/python3.6/subprocess.py", line 1364, in _execute_child
    raise child_exception_type(errno_num, err_msg, err_filename)
FileNotFoundError: [Errno 2] No such file or directory: 'gsutil': 'gsutil'
```

## Sources

* [Tensorflow installation guide](https://www.tensorflow.org/install/gpu)
* [Tensorflow install issues](https://github.com/tensorflow/tensorflow/issues/26182)
* [Tensorflow GPU guide](https://www.tensorflow.org/guide/gpu)
