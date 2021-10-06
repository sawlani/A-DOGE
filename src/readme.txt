First, run the MATLAB scripts in src/MATLAB/data_processing to preprocess datasets into the required format. Use the following command:

load_dataset(dataset_name)

Next, generate A-DOGE embedding using the following script:

generate_ADOGE(dataset_name)

For other baseline embeddings, use the respective MATLAB script:

generate_FGSD(dataset_name)
generate_DOSGK(dataset_name)

Other baselines are in PYTHON, use:

python generate_G2V.py --dataset=dataset_name
python generate_NetLSD.py --dataset=dataset_name
python generate_baseline_kernels.py --kernel=[WL/PK/WLOA] --dataset=dataset_name

Once the embeddings are generated, run the respective classification experiment:

python classifier.py --dataset=dataset_name --embedder=embedding_or_kernel_type


One full example:

load_dataset("PROTEINS")
generate_ADOGE("PROTEINS")
python classifier.py --dataset="PROTEINS" --embedder=dos_ldos
