function [put_k_modeli, imya_modeli] = zapusk_simulink_stenda_roya()
koren_proekta = fileparts(mfilename('fullpath'));
dobavit_puti_dlya_stenda(koren_proekta);

[put_k_modeli, imya_modeli] = otkryt_model_stenda_roya(koren_proekta);
soobshchenie('Simulink-представление стенда роя БВС открыто');
end

function dobavit_puti_dlya_stenda(koren_proekta)
addpath(fullfile(koren_proekta, 'raschet', 'otsenka'));
addpath(fullfile(koren_proekta, 'raschet', 'bvs'));
addpath(fullfile(koren_proekta, 'raschet', 'sreda'));
addpath(fullfile(koren_proekta, 'raschet', 'svyaz'));
addpath(fullfile(koren_proekta, 'raschet', 'zveno'));
addpath(fullfile(koren_proekta, 'raschet', 'peredacha'));
addpath(fullfile(koren_proekta, 'raschet', 'scenarii'));
addpath(fullfile(koren_proekta, 'visualization'));
addpath(fullfile(koren_proekta, 'apps'));
addpath(fullfile(koren_proekta, 'bloki', 'sozdanie_modelei'));
end
