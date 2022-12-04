%%%%  ����ÿһ�й�һ��������Ȼ��������ƽ�������ž��������Ƚ��ĸ����ӽ�
%%%  �����Ǿ�γ�ȵ���Ϣ������Ȩ��һ�Σ�Ŀ����Ҫ�ҳ���Щ�����ھ�γ�ȶ����ֽŵ��ظ���

clear
clc

for nian=2008:2008
    eval(['load DNA_summary_',num2str(nian),'.mat'])
    
    
    DNA_series_copy=DNA_series(:,[1:2,5:19,21:34]);  %ȥ����γ�Ⱥ�WMO_ID���ڵ���
    
    %��׼������mapstd  �����ݱ�׼��Ϊ��ֵΪ0������Ϊ1������    mapminmax��һ��
    DNA_mapped=mapminmax(DNA_series_copy,0,1);
    DNA_mapped(DNA_series_copy==0)=0;
    
    %%%%%%%%%%��Ȩ��
    [weight]=entropy_weight(DNA_series_copy);
    
    figure(); bar(weight)
    %%%%%%%%%%  ��Ȩƽ��
    average_DNA_single=NaN(size(DNA_mapped));
    for i=1:length(weight)
        average_DNA_single(:,i)=DNA_mapped(:,i)*weight(i);
    end
    average_DNA=sum(average_DNA_single,2,'omitnan');
    
    %��average_DNA�����������򣬷�����������㷨�Ľ���
    [average_DNA,index]=sort(average_DNA);
    filename_info=filename_info(index,:);
    DNA_mapped=DNA_mapped(index,:);
    DNA_series=DNA_series(index,:);
    DNA_series_copy=DNA_series_copy(index,:);
    
    figure();plot(average_DNA,'o')
    
    %%% ѭ������
    output_variables=['filename',variable_name];
    filename=['./potential_duplicates_output/',num2str(nian),'/potential_duplicat_',num2str(nian),'_weight_noLATLON.txt'];
    if(exist(filename))
        delete(filename)
    end
    fid=fopen(filename,'w+');
    % for i=1:length(output_variables)
    %     fprintf(fid,'%s ',output_variables{i})
    % end
    % output_filename='potential_duplicates.xlsx';
    
    number_pairs=0;
    number_profiles=0;
    for i=1:length(average_DNA)
        i
        number1=average_DNA(i);
        difference=abs((number1-average_DNA)/number1*100);   %����ٷֱ�
        difference(1:i-1)=NaN;
        duplicate_number=sum(difference<0.0001);   %��ֵ0.001%      ��ֵ������֮���趨����
        if(duplicate_number>=2)
            %%%%�����ظ�
            %        pause
            %��difference�����С�����Ϊ0��
            difference(i)=NaN;
            id=[i;find(difference==nanmin(difference))];
            DNA_series_small=DNA_series(id,:);
            %%%%%%%%%%%%%%%%%%%����Ǹ���MRB���ݣ������� ���xxxxxxx
            if(DNA_series(i,2)==7)
                continue
            end
            
            
            %%%%%%%%%����һ��һЩ�ų����ж� �����ж�����Ƭ���ж��ٸ���
            fragment_same_number=sum(abs(DNA_series_small(1,:)-DNA_series_small(2,:))<1e-5,'omitnan');
            if(fragment_same_number<26)  %һ��31��Ƭ��  %%%%%%%������Էּ�������׼ȷ�ظ����ϸ����33 ����32  �ĳ�27�����ҳ����󲿷�׼ȷ�ظ�
                continue
            end   %��ʵ�������ѭ����һ��
            
            %%%%�����XBT CTD MBT BOT������һ�������������5�ȣ�����ͬһ��probe  �ų��ߺ������۲�
            %%%%type,platform,vehicle,����sum_temp,corr(temp,depth)��һ�������ж�Ϊͬһ������ ͬһ�����鴬/ƽ̨ �ϵĶ�ι۲�
            if((DNA_series_small(1,2)==4 && DNA_series_small(2,2)==4) || (DNA_series_small(1,2)==2 && DNA_series_small(2,2)==2) || (DNA_series_small(1,2)==1 && DNA_series_small(2,2)==1) || (DNA_series_small(1,2)==3 && DNA_series_small(2,2)==3))
                index1=all(DNA_series_small(1,[5,6,8,23,24,26])==DNA_series_small(2,[5,6,8,23,24,26]));  %��Ҫһ��
                index2= abs(DNA_series_small(1,27)-DNA_series_small(2,27))>0.099; %sum_temp�����
                index3= abs(DNA_series_small(1,33)-DNA_series_small(2,33))>0.001;  %cor_temp_depth
                index4=any(abs(DNA_series_small(1,[3,4])-DNA_series_small(2,[3,4]))<5) && any(abs(DNA_series_small(1,[3,4])-DNA_series_small(2,[3,4]))>1e-5);
                if(index1 && index2 && index3 && index4)
                    continue
                end
            end
            %%%%%�ų�����/�����㳤ʱ�������۲� ֻ��MRB Bottle SUR
            if((DNA_series_small(1,2)==1 && DNA_series_small(2,2)==1) || (DNA_series_small(1,2)==7 && DNA_series_small(2,2)==7) || (DNA_series_small(1,2)==5 && DNA_series_small(2,2)==5))
                index1=all(DNA_series_small(1,[5,6,8,9,22,23,24])==DNA_series_small(2,[5,6,8,9,22,23,24]));  %��Ҫһ��
                index2=abs(DNA_series_small(1,27)-DNA_series_small(2,27))>0.05; %sum_temp�����
                index3=abs(DNA_series_small(1,29)-DNA_series_small(2,29))<1e-5;  %sum_depth���
                index4=all(abs(DNA_series_small(1,[3,4])-DNA_series_small(2,[3,4]))<0.01);  %���㣺��γ��С��0.01��
                if(index1 && index2 && index3 && index4)
                    continue
                end
            end
            
            
            %%%%%���ԭʼ�����ļ�
            for m=1:length(id)
                fprintf(fid,'%s ',filename_info(id(m),:));
            end
            fprintf(fid,'\n');
            
            %%%%%���ԭʼ�����ļ�
            %         fprintf(fid,'%s\n','��Potential Duplicates pairs��:');
            %         for m=1:length(id)
            %             fprintf(fid,'%s ',filename_info(id(m),:));
            %             fprintf(fid,'%3d %.4f %.4f %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %3d %.4f %.4f %3d %.4f %.4f %.4f %.4f %.4f\n',DNA_series(id(m),:));
            %         end
            %         fprintf(fid,'\n');
            %                pause
            number_pairs=number_pairs+1;
            number_profiles=number_profiles+duplicate_number;
            
        end
    end
    
    number_pairs
    number_profiles
end

%%

% for i=1:length(filename_info(:,1))
%     filename=filename_info(i,:);
%     if(contains(filename,'CASv1_T_19950713_00728_BOT.nc') || contains(filename,'CASv1_T_19950713_00727_BOT.nc'))
%         i
%     end
% end