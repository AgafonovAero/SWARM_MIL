function pult = zapusk_pulta_issledovatelya()
koren_proekta = fileparts(mfilename('fullpath'));
dobavit_puti_dlya_pulta(koren_proekta);

pult = sozdat_pult_issledovatelya(koren_proekta, true);
soobshchenie('Пульт исследователя успешно запущен.');
end

function dobavit_puti_dlya_pulta(koren_proekta)
addpath(fullfile(koren_proekta, 'raschet', 'otsenka'));
addpath(fullfile(koren_proekta, 'raschet', 'bvs'));
addpath(fullfile(koren_proekta, 'raschet', 'sreda'));
addpath(fullfile(koren_proekta, 'raschet', 'svyaz'));
addpath(fullfile(koren_proekta, 'raschet', 'zveno'));
addpath(fullfile(koren_proekta, 'raschet', 'peredacha'));
addpath(fullfile(koren_proekta, 'raschet', 'scenarii'));
addpath(fullfile(koren_proekta, 'visualization'));
addpath(fullfile(koren_proekta, 'apps'));
end
