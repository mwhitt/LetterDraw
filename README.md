# Hand drawn letter recognizer
Experiment to recreate a hand drawn, single character ML model on par with the Apple Watch app.

## Setup Xcode

Download the latest iOS **opencv** framework into the `LetterDraw` folder at the root of the project:
https://opencv.org/releases/

## Setup Training Model

Setup a python virtual environment:  
https://medium.com/@MattGosden/set-up-your-mac-for-python-and-jupyter-using-virtual-environments-730bf2888e05

Install requirements:  
`pip install keras==2.2.4 tensorflow==1.14.0 coremltools`

Download **emnist-letters-test.csv** & **emnist-letters-train.csv** into the `data` directory:  
https://www.kaggle.com/crawford/emnist

