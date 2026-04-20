function nagruzka_golovnyh_bvs = raschet_nagruzki_golovnyh_bvs(rezultat_zvenev, rezultat_peredachi)
if nargin < 2
    error('%s', [ ...
        'Для расчета нагрузки головных БВС требуются результаты звеньев ' ...
        'и передачи сообщений.' ...
        ]);
end

rezultat_zvenev = proverit_rezultat_zvenev(rezultat_zvenev);
rezultat_peredachi = proverit_rezultat_peredachi(rezultat_peredachi);

id_bvs = sobrat_id_bvs(rezultat_zvenev, rezultat_peredachi);
chislo_bvs = numel(id_bvs);
chislo_momentov = numel(rezultat_zvenev.vremya);

chislo_momentov_golovnogo_bvs = zeros(1, chislo_bvs);
for nomer_momenta = 1:chislo_momentov
    golovnye_bvs = rezultat_zvenev.golovnye_bvs_po_vremeni{nomer_momenta};
    for nomer_golovnogo = 1:numel(golovnye_bvs)
        indeks = nayti_indeks_bvs(id_bvs, golovnye_bvs{nomer_golovnogo});
        chislo_momentov_golovnogo_bvs(indeks) = ...
            chislo_momentov_golovnogo_bvs(indeks) + 1;
    end
end

chislo_soobshchenii_cherez_golovnogo_bvs = zeros(1, chislo_bvs);
for nomer_soobshcheniya = 1:numel(rezultat_peredachi.soobshcheniya)
    marshrut = rezultat_peredachi.soobshcheniya(nomer_soobshcheniya).marshrut;
    if numel(marshrut) <= 2
        continue
    end

    vnutrennie_uzly = marshrut(2:end-1);
    for nomer_uzla = 1:numel(vnutrennie_uzly)
        indeks = nayti_indeks_bvs(id_bvs, vnutrennie_uzly{nomer_uzla});
        chislo_soobshchenii_cherez_golovnogo_bvs(indeks) = ...
            chislo_soobshchenii_cherez_golovnogo_bvs(indeks) + 1;
    end
end

if max(chislo_soobshchenii_cherez_golovnogo_bvs) > 0
    normirovannyi_potok = chislo_soobshchenii_cherez_golovnogo_bvs ...
        / max(chislo_soobshchenii_cherez_golovnogo_bvs);
else
    normirovannyi_potok = zeros(1, chislo_bvs);
end

dolya_vremeni_golovnogo_bvs = chislo_momentov_golovnogo_bvs / max(1, chislo_momentov);
otnositelnaya_nagruzka = min(1.0, ...
    0.5 * dolya_vremeni_golovnogo_bvs + 0.5 * normirovannyi_potok);

nagruzka_golovnyh_bvs = struct();
nagruzka_golovnyh_bvs.id_bvs = id_bvs;
nagruzka_golovnyh_bvs.chislo_momentov_golovnogo_bvs = ...
    chislo_momentov_golovnogo_bvs;
nagruzka_golovnyh_bvs.dolya_vremeni_golovnogo_bvs = ...
    dolya_vremeni_golovnogo_bvs;
nagruzka_golovnyh_bvs.chislo_soobshchenii_cherez_golovnogo_bvs = ...
    chislo_soobshchenii_cherez_golovnogo_bvs;
nagruzka_golovnyh_bvs.otnositelnaya_nagruzka_golovnogo_bvs = ...
    otnositelnaya_nagruzka;
nagruzka_golovnyh_bvs.primechanie = [ ...
    'Нагрузка головных БВС оценена по доле времени в роли головного БВС ' ...
    'и числу сообщений, проходящих через маршрут.' ...
    ];
end

function rezultat_zvenev = proverit_rezultat_zvenev(rezultat_zvenev)
if ~isstruct(rezultat_zvenev) ...
        || ~isfield(rezultat_zvenev, 'vremya') ...
        || ~isfield(rezultat_zvenev, 'golovnye_bvs_po_vremeni')
    error('%s', ...
        'Результат звеньев должен содержать временную ось и головные БВС.');
end
end

function rezultat_peredachi = proverit_rezultat_peredachi(rezultat_peredachi)
if ~isstruct(rezultat_peredachi) ...
        || ~isfield(rezultat_peredachi, 'soobshcheniya')
    error('%s', ...
        'Результат передачи должен содержать список сообщений.');
end
end

function id_bvs = sobrat_id_bvs(rezultat_zvenev, rezultat_peredachi)
id_bvs = {};

for nomer_momenta = 1:numel(rezultat_zvenev.golovnye_bvs_po_vremeni)
    golovnye_bvs = rezultat_zvenev.golovnye_bvs_po_vremeni{nomer_momenta};
    for nomer_golovnogo = 1:numel(golovnye_bvs)
        id_bvs = dobavit_unikalnoe_znachenie(id_bvs, golovnye_bvs{nomer_golovnogo});
    end

    zvenya = rezultat_zvenev.zvenya_po_vremeni{nomer_momenta};
    for nomer_zvena = 1:numel(zvenya)
        for nomer_bvs = 1:numel(zvenya(nomer_zvena).id_bvs)
            id_bvs = dobavit_unikalnoe_znachenie( ...
                id_bvs, zvenya(nomer_zvena).id_bvs{nomer_bvs});
        end
    end
end

for nomer_soobshcheniya = 1:numel(rezultat_peredachi.soobshcheniya)
    marshrut = rezultat_peredachi.soobshcheniya(nomer_soobshcheniya).marshrut;
    for nomer_tochki = 1:numel(marshrut)
        id_bvs = dobavit_unikalnoe_znachenie(id_bvs, marshrut{nomer_tochki});
    end
end
end

function indeks = nayti_indeks_bvs(id_bvs, iskomyi_id)
indeks = find(strcmp(id_bvs, char(string(iskomyi_id))), 1);
if isempty(indeks)
    error('%s', sprintf( ...
        'Не найден идентификатор БВС %s в расчете нагрузки головных БВС.', ...
        char(string(iskomyi_id))));
end
end

function spisok = dobavit_unikalnoe_znachenie(spisok, znachenie)
znachenie = char(string(znachenie));
if strlength(string(znachenie)) == 0
    return
end

if ~any(strcmp(spisok, znachenie))
    spisok{end + 1} = znachenie; %#ok<AGROW>
end
end
