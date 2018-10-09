%% relevant results file

% in the final table, the nets are ordered according to their performances,
% by column (i.e. 1st column represent the best net, 2nd column the seconf
% best net and so on)

% for heat
% 1) all_75 e = 3 g = 19
% 2) all_55 e = 2 g = 27
% 3) all_35 e = 2 g = 7
% 4) all_43 e = 2 g = 15
% 5) all_51 e = 2 g = 23
% 6) all_47 e = 2 g = 19
% 7) all_67 e = 3 g = 11
nets_heat = [75, 55, 35, 43, 51, 47, 67];

% relevant nets
% for elec, considering season 1 and 3:
% 1) all_deseason_40 e = 2 g = 12
% 2) all_deseason_44 e = 2 g = 16
% 3) all_deseason_80 e = 3 g = 24
% 4) all_deseason_76 e = 3 g = 20
% 5) all_deseason_72 e = 3 g = 16
% 6) all_deseason_68 e = 3 g = 12
% 7) all_deseason_32 e = 2 g = 4
nets_elec = [40  44  80  76  72  68  32];



kind = ["heating" , "elec"];
shift_out_num = 3; % out_num is the name of the output -> considered from 1 plus the constant shift
%% load the data from results
for m = 1:2
    for n = 1:3
        for i = 1:28
            
            %  m= 1;
            %n = 1;
            %  i = 1;
            all = [];
            for out_num = 1:3
                
                %out_num = 4;
                %i = 1;
                %n = 3;
                %m = 2;
                
                file_name = string(i) + '_output_' + string(out_num + shift_out_num) + '.dat';
                save_name = string(i) + '_best_output_1.dat';
                load_path = 'Results/season' + string(n) + '/' + kind(m) +  '/';
                save_path = 'Results/season' + string(n) + '/' + kind(m) +  '/';
                figure_name = string(i) + '_best_output_figure_1';
                %data = csvread(load_path + file_name)';
                T = readtable(load_path + file_name);
                A = table2array(T(:, 1:end - 1));
                
                
                all = [all A] ;
            end
            
            %% heat
            
            if (m == 1 )
                best_heat = [];
                for net = 1:size(nets_heat,2)
                    best_heat = [best_heat all(:,nets_heat(net))];
                end
                best_heat = [best_heat table2array(T(: ,end))];
                table_pred = array2table(best_heat, 'VariableNames', {'all_75','all_55','all_35','all_43','all_51','all_47','all_67', 'original'});
                result_path = fullfile(save_path, save_name);
                writetable(table_pred, result_path);
                
                % plot(best_heat)
                
                f_1 = figure;
                title (figure_name)
                % plot predicitons
                for k = 1:size(best_heat,2) - 1
                    plot(best_heat(:,k));
                    hold on
                end
                % plot orignal data
                plot(best_heat(:,end), 'LineWidth', 2)
                hold on
                plot_legend = {'all_75','all_55','all_35','all_43','all_51','all_47','all_67', 'original'};
                legend (plot_legend);
                temp = save_path + figure_name;
                saveas(f_1,temp , 'fig');
                hold off
                close(f_1);
                
            end
            
            
            
            %% elec
            if (m == 2)
                best_elec = [];
                for net = 1:size(nets_elec,2)
                    best_elec = [best_elec all(:,nets_elec(net))];
                end
                best_elec = [best_elec table2array(T(: ,end))];
                table_pred = array2table(best_elec, 'VariableNames', {'all_deseason_40','all_deseason_44','all_deseason_80','all_deseason_76','all_deseason_72','all_deseason_68','all_deseason_32', 'original'});
                result_path = fullfile(save_path, save_name);
                writetable(table_pred, result_path);
                
                f_1 = figure;
                title (figure_name)
                % plot predicitons
                for k = 1:size(best_elec,2) - 1
                    plot(best_elec(:,k));
                    hold on
                end
                % plot orignal data
                plot(best_elec(:,end), 'LineWidth', 2)
                hold on
                plot_legend = {'all_deseason_40','all_deseason_44','all_deseason_80','all_deseason_76','all_deseason_72','all_deseason_68','all_deseason_32', 'original'};
                legend (plot_legend);
                temp = save_path + figure_name;
                saveas(f_1,temp , 'fig');
                hold off
                close(f_1);
            end
            
            (m-1) * 3 * 28 + (n-1) * 28 + i % counter to check progression of the work
            
        end
    end
    
end

"end"
