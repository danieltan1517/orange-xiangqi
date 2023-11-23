CONTRIBUTING GUIDELINES
=======================

## 💻 Compilation
This project requires Jai Compiler (beta-1-076) to build the oriange engine. There is a build script 'build.jai' provided. Please run `jai build.jai` to get the detailed help information.

#### Commands to build the Engine

To build the engine with the game UI, please run the following command:
```
jai build.jai - all
```

Or, you can add `release` for a release build.

```
jai build.jai - all release
```

You can use `clean` to clean the workspace.
```
jai build.jai - clean
```


#### Build the Main Engine with NNUE Support

NNUE is an efficiently updatable neural network designed for providing evaluation functions. We can support build with NNUE model to get better result. 

To build with NNUE Support (and with avx2 instructions to speedup inference), please run:
```
jai build - all nnue avx2
```
There are three avaliable options avx2, sse and cpu for different NNUE implementations. 



## 📥 Opening an Issue
Before creating an issue, check if you are using the latest version of the project. If you are not up-to-date, see if updating fixes your issue first.

**Feature Request** is welcome. Please mark your issue with the `feature` tag.

Writing **Bug Reports** is a great way to contribute to the project when you encounter a problem. We always appreciate a well-written, thorough bug report. Please mark your issue with the `bug` tag.



## Creating an Opening Book

Opening book helps a lot for the engine to get a humain like opening game. To create it, you need first to download the game dataset:

```
jai build - games
```

There is a book generator `book_generator.jai` to generate the code `opening_book.jai` which contains the data embedded in jai source code. You can run the following command to update this file:

```
jai book_generator.jai
```
This tool will read the file `xiangqi_games.txt` and converted it into jai source code.


## Trainning Your NNUE Model

Please refer [xiangqi_pytorch](https://github.com/danieltan1517/xiangqi_pytorch) to train your own model.
