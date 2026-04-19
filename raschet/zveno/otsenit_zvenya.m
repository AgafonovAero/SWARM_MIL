function pokazateli = otsenit_zvenya(rezultat_zvenev, rezultat_golovnyh_bvs, graf_svyaznosti)

if nargin < 3
    error('%s', [ ...
        'Для оценки звеньев требуются результат звеньев, назначение ' ...
        'головных БВС и граф связности.' ...
        ]);
end

proverit_rezultat_zvenev(rezultat_zvenev);
proverit_rezultat_golovnyh(rezultat_golovnyh_bvs);
matrica_poleznosti_linii = poluchit_matricu_poleznosti(graf_svyaznosti);

zvenya = rezultat_golovnyh_bvs.zvenya;
razmery = [zvenya.razmer_zvena];

vse_vnutrennie_poleznosti = [];
for nomer_zvena = 1:numel(zvenya)
    indeksy = zvenya(nomer_zvena).indeksy_bvs;
    if numel(indeksy) < 2
        continue
    end

    podmatrica = matrica_poleznosti_linii(indeksy, indeksy);
    maska_verhnego_treugolnika = triu(true(size(podmatrica)), 1);
    znacheniya = podmatrica(maska_verhnego_treugolnika);
    vse_vnutrennie_poleznosti = [vse_vnutrennie_poleznosti; znacheniya(:)]; %#ok<AGROW>
end

if isempty(vse_vnutrennie_poleznosti)
    srednyaya_poleznost = 0;
else
    srednyaya_poleznost = mean(vse_vnutrennie_poleznosti);
end

dolya_bvs_v_zvenyah = sum(rezultat_zvenev.nomer_zvena_dlya_bvs > 0) ...
    / numel(rezultat_zvenev.id_bvs);
chislo_zvenev_s_golovnym = sum(~cellfun(@isempty, rezultat_golovnyh_bvs.golovnye_bvs));
dolya_zvenev_s_golovnym = chislo_zvenev_s_golovnym / numel(zvenya);

pokazateli = struct();
pokazateli.chislo_zvenev = rezultat_zvenev.chislo_zvenev;
pokazateli.chislo_odinochnyh_zvenev = rezultat_zvenev.chislo_odinochnyh_zvenev;
pokazateli.srednii_razmer_zvena = mean(razmery);
pokazateli.maksimalnyi_razmer_zvena = max(razmery);
pokazateli.srednyaya_poleznost_linii_vnutri_zvenev = srednyaya_poleznost;
pokazateli.dolya_bvs_naznachennyh_v_zvenya = dolya_bvs_v_zvenyah;
pokazateli.dolya_zvenev_s_golovnym_bvs = dolya_zvenev_s_golovnym;
pokazateli.primechanie = [ ...
    'Показатели звеньев рассчитаны без маршрутизации, управления и ' ...
    'изменения траекторий БВС.' ...
    ];

proverit_konechnost_pokazateley(pokazateli);
end

function proverit_rezultat_zvenev(rezultat_zvenev)
if ~isstruct(rezultat_zvenev) || ~isfield(rezultat_zvenev, 'zvenya')
    error('%s', ...
        'Результат звеньев должен быть передан в виде структуры.');
end
end

function proverit_rezultat_golovnyh(rezultat_golovnyh_bvs)
if ~isstruct(rezultat_golovnyh_bvs) ...
        || ~isfield(rezultat_golovnyh_bvs, 'zvenya') ...
        || ~isfield(rezultat_golovnyh_bvs, 'golovnye_bvs')
    error('%s', [ ...
        'Результат назначения головных БВС должен содержать звенья и ' ...
        'список головных БВС.' ...
        ]);
end
end

function matrica_poleznosti_linii = poluchit_matricu_poleznosti(graf_svyaznosti)
if ~isstruct(graf_svyaznosti) || ~isfield(graf_svyaznosti, 'matrica_poleznosti_linii')
    error('%s', [ ...
        'Граф связности должен содержать матрицу полезности линий для ' ...
        'оценки звеньев.' ...
        ]);
end

matrica_poleznosti_linii = double(graf_svyaznosti.matrica_poleznosti_linii);
if ~all(isfinite(matrica_poleznosti_linii(:)))
    error('%s', [ ...
        'Матрица полезности линий для оценки звеньев должна содержать ' ...
        'только конечные значения.' ...
        ]);
end
end

function proverit_konechnost_pokazateley(pokazateli)
chisla = [ ...
    pokazateli.chislo_zvenev
    pokazateli.chislo_odinochnyh_zvenev
    pokazateli.srednii_razmer_zvena
    pokazateli.maksimalnyi_razmer_zvena
    pokazateli.srednyaya_poleznost_linii_vnutri_zvenev
    pokazateli.dolya_bvs_naznachennyh_v_zvenya
    pokazateli.dolya_zvenev_s_golovnym_bvs
    ];

if ~all(isfinite(chisla))
    error('%s', 'Показатели качества звеньев должны быть конечными.');
end
end
