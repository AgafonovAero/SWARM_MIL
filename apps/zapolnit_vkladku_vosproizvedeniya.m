function elementy = zapolnit_vkladku_vosproizvedeniya(vkladka)
maket = uigridlayout(vkladka, [2, 1]);
maket.RowHeight = {'1x', 90};
maket.ColumnWidth = {'1x'};
maket.Padding = [10, 10, 10, 10];

osi = uiaxes(maket);
osi.Layout.Row = 1;
osi.Layout.Column = 1;
title(osi, 'Трехмерная сцена роя');
grid(osi, 'on');
view(osi, 3);

panel_upravleniya = uigridlayout(maket, [2, 7]);
panel_upravleniya.Layout.Row = 2;
panel_upravleniya.Layout.Column = 1;
panel_upravleniya.RowHeight = {32, 32};
panel_upravleniya.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', 120, 160};

polzunok_kadra = uislider(panel_upravleniya);
polzunok_kadra.Layout.Row = 1;
polzunok_kadra.Layout.Column = [1, 5];
polzunok_kadra.Limits = [1, 2];
polzunok_kadra.Value = 1;

knopka_pervyi = uibutton(panel_upravleniya, 'push', 'Text', 'Первый кадр');
knopka_pervyi.Layout.Row = 2;
knopka_pervyi.Layout.Column = 1;

knopka_nazad = uibutton(panel_upravleniya, 'push', 'Text', 'Назад');
knopka_nazad.Layout.Row = 2;
knopka_nazad.Layout.Column = 2;

knopka_vpered = uibutton(panel_upravleniya, 'push', 'Text', 'Вперед');
knopka_vpered.Layout.Row = 2;
knopka_vpered.Layout.Column = 3;

knopka_poslednii = uibutton(panel_upravleniya, 'push', 'Text', 'Последний кадр');
knopka_poslednii.Layout.Row = 2;
knopka_poslednii.Layout.Column = 4;

knopka_obnovit = uibutton(panel_upravleniya, 'push', 'Text', 'Обновить сцену');
knopka_obnovit.Layout.Row = 2;
knopka_obnovit.Layout.Column = 5;

pole_nomer_kadra = uieditfield(panel_upravleniya, 'numeric');
pole_nomer_kadra.Layout.Row = [1, 2];
pole_nomer_kadra.Layout.Column = 6;
pole_nomer_kadra.Editable = 'off';
pole_nomer_kadra.Value = 1;

pole_tekushego_vremeni = uieditfield(panel_upravleniya, 'text');
pole_tekushego_vremeni.Layout.Row = [1, 2];
pole_tekushego_vremeni.Layout.Column = 7;
pole_tekushego_vremeni.Editable = 'off';
pole_tekushego_vremeni.Value = 't = 0.00 с';

elementy = struct();
elementy.maket = maket;
elementy.osi = osi;
elementy.polzunok_kadra = polzunok_kadra;
elementy.knopka_pervyi = knopka_pervyi;
elementy.knopka_nazad = knopka_nazad;
elementy.knopka_vpered = knopka_vpered;
elementy.knopka_poslednii = knopka_poslednii;
elementy.knopka_obnovit = knopka_obnovit;
elementy.pole_nomer_kadra = pole_nomer_kadra;
elementy.pole_tekushego_vremeni = pole_tekushego_vremeni;
end
