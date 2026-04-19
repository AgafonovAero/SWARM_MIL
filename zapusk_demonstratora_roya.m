function rezultat = zapusk_demonstratora_roya()
koren_proekta = fileparts(mfilename('fullpath'));

dobavit_puti_proekta(koren_proekta);

demonstraciya = sobrat_dannye_demonstracii_roya(koren_proekta, 'stroi_malyi');
dannye_vizualizacii = podgotovit_dannye_vizualizacii(demonstraciya);

grafika = postroit_scenu_roya_3d(dannye_vizualizacii, true);
grafiki = postroit_grafiki_pokazatelei(dannye_vizualizacii, true);

for nomer_kadra = 1:numel(dannye_vizualizacii.kadry)
    grafika = obnovit_kadr_roya(grafika, dannye_vizualizacii, nomer_kadra);
    drawnow
    pause(0.05);
end

rezultat = struct();
rezultat.demonstraciya = demonstraciya;
rezultat.dannye_vizualizacii = dannye_vizualizacii;
rezultat.grafika = grafika;
rezultat.grafiki = grafiki;

soobshchenie([ ...
    'Подготовка демонстратора роя завершена. Открыты трехмерная сцена ' ...
    'и графики показателей.' ...
    ]);
end

function dobavit_puti_proekta(koren_proekta)
addpath(fullfile(koren_proekta, 'raschet', 'otsenka'));
addpath(fullfile(koren_proekta, 'raschet', 'bvs'));
addpath(fullfile(koren_proekta, 'raschet', 'sreda'));
addpath(fullfile(koren_proekta, 'raschet', 'svyaz'));
addpath(fullfile(koren_proekta, 'raschet', 'zveno'));
addpath(fullfile(koren_proekta, 'raschet', 'peredacha'));
addpath(fullfile(koren_proekta, 'raschet', 'scenarii'));
addpath(fullfile(koren_proekta, 'visualization'));
end
