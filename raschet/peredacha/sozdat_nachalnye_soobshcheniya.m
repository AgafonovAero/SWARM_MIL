function soobshcheniya = sozdat_nachalnye_soobshcheniya(scenarii, parametry_peredachi)
if nargin < 1 || ~isstruct(scenarii)
    error('%s', ...
        'Для создания начальных сообщений требуется структура сценария.');
end

if nargin < 2 || isempty(parametry_peredachi)
    parametry_peredachi = parametry_peredachi_po_umolchaniyu();
else
    parametry_peredachi = proverit_parametry_peredachi(parametry_peredachi);
end

proverit_scenarii(scenarii, 'структура сценария для создания сообщений');

chislo_bvs = numel(scenarii.sostav_roya);
if chislo_bvs < 2
    error('%s', ...
        'Для создания сообщений в сценарии требуется не менее двух БВС.');
end

rng(double(scenarii.nachalnoe_chislo), 'twister');

identifikatory_bvs = cell(1, chislo_bvs);
for nomer_bvs = 1:chislo_bvs
    identifikatory_bvs{nomer_bvs} = char(string( ...
        scenarii.sostav_roya(nomer_bvs).id_bvs));
end

chislo_soobshchenii = min(3, chislo_bvs);
poryadok = randperm(chislo_bvs);
tipy_soobshchenii = {
    'sluzhebnoe'
    'issledovatelskoe'
    'sluzhebnoe'
    };
soobshcheniya = struct([]);

for nomer_soobshcheniya = 1:chislo_soobshchenii
    nomer_otpravitelya = poryadok(nomer_soobshcheniya);
    nomer_poluchatelya = poryadok(mod(nomer_soobshcheniya, chislo_bvs) + 1);
    id_otpravitelya = identifikatory_bvs{nomer_otpravitelya};
    id_poluchatelya = identifikatory_bvs{nomer_poluchatelya};
    razmer_soobshcheniya_bit = ...
        parametry_peredachi.bazovyi_razmer_soobshcheniya_bit ...
        * (1 + 0.25 * mod(nomer_soobshcheniya - 1, 2));
    tip_soobshcheniya = tipy_soobshchenii{nomer_soobshcheniya};

    tekushchee_soobshchenie = sozdat_soobshchenie( ...
        sprintf('soobshchenie_%03d', nomer_soobshcheniya), ...
        id_otpravitelya, ...
        id_poluchatelya, ...
        0.0, ...
        razmer_soobshcheniya_bit, ...
        tip_soobshcheniya);

    if isempty(soobshcheniya)
        soobshcheniya = repmat(tekushchee_soobshchenie, 1, chislo_soobshchenii);
    end

    soobshcheniya(nomer_soobshcheniya) = tekushchee_soobshchenie;
end
end
