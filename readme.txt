This code is a simple implementation of RPCA.
By Xue Shengke, Zhejiang University, March 2017.

You may start an example by directly running 'example_*.m' for various datasets.
|--------------
|-- example_COIL.m
|-- example_dummy.m       
|-- example_GTF.m
|-- example_MNIST.m     
|-- example_ORL.m
|-- example_Yale.m  
|-------------

The code contains:
|--------------
|-- data/                     directory for image datasets *.mat
|-- figure/                   directory for saving figures
|-- load_func/                functions for loading datasets
|-- RPCA_func/                RPCA functions for robust alignment
    |-- RPCA_iALM.m           inexact ALM algorithm
    |-- RPCA_main.m           main function of RPCA
    |-- RPCA_plot.m           display some image results after alignment
|-- result/                   directory for saving experimental results
|-- util/                     fundamental functions
|-------------

Note that, our code adopts the inexact augmented Lagrange multiplier (ALM) 
method throughout this implementation.

For algorithm details, please read the RPCA paper, which explains more details.

If you have any questions about this implementation, please do not hesitate to contact us. 

Xue Shengke, 
College of Information Science and Electronic Engineering,
Zhejiang University, P. R. China
e-mail: (either one is o.k.)
xueshengke@zju.edu.cn, or xueshengke1993@gmail.com