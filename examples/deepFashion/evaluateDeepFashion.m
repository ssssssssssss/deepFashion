close all;
clear;

% -- settings start here ---
% set 1 to use gpu, and 0 to use cpu
use_gpu = 1;

% top K returned images
top_k = 30;
feat_len = 48;

% % set result folder
 result_folder = '/home/ubuntu/caffe-cvprw15/examples/deepFashion/analysis';

% % models
model_file = '/home/ubuntu/caffe-cvprw15/examples/deepFashion/models/deepFashion_Jabong_48_iter_50000.caffemodel';
% % model definition
model_file = '/data/snapshot/deepFashion_Jabong_48_color_label_iter_50000.caffemodel';
model_def_file='/home/ubuntu/caffe-cvprw15/examples/deepFashion/modelDef/deepFashion_48_deploy.prototxt'
% % train-test
test_file_list = '/home/ubuntu/caffe-cvprw15/examples/deepFashion/test.txt.data';
test_label_file = '/home/ubuntu/caffe-cvprw15/examples/deepFashion/test.txt.labels';
train_file_list = '/home/ubuntu/caffe-cvprw15/examples/deepFashion/train.txt.data';
train_label_file = '/home/ubuntu/caffe-cvprw15/examples/deepFashion/train.txt.labels';
% % --- settings end here ---

% result_folder = '/home/ubuntu/caffe-cvprw15/examples/deepFashion/analysis'
%result_folder = '/home/siddhantmanocha/Projects/neural/deepFashion/examples/deepFashion/analysis'
% models
%model_file = '/home/siddhantmanocha/Projects/neural/deepFashion/examples/deepFashion/models/deepFashion_Jabong_48_iter_50000.caffemodel';
% model definition
%model_def_file = '/home/siddhantmanocha/Projects/neural/deepFashion/examples/deepFashion/modelDef/deepFashion_48_deploy.prototxt';

% train-test
%test_file_list = '/home/siddhantmanocha/Projects/neural/deepFashion/examples/deepFashion/test.txt.data';
%test_label_file = '/home/siddhantmanocha/Projects/neural/deepFashion/examples/deepFashion/test.txt.labels';
%train_file_list = '/home/siddhantmanocha/Projects/neural/deepFashion/examples/deepFashion/train.txt.data';
%train_label_file = '/home/siddhantmanocha/Projects/neural/deepFashion/examples/deepFashion/train.txt.labels';
% ----------- settings end here ----------------



% outputs
feat_test_file = sprintf('%s/feat-test.mat', result_folder);
feat_train_file = sprintf('%s/feat-train.mat', result_folder);
binary_test_file = sprintf('%s/binary-test.mat', result_folder);
binary_train_file = sprintf('%s/binary-train.mat', result_folder);

% map and precision outputs
map_file = sprintf('%s/map.txt', result_folder);
precision_file = sprintf('%s/precision-at-k.txt', result_folder);

% feature extraction- test set
if exist(binary_test_file, 'file') ~= 0
    load(binary_test_file);
    fprintf('loading the parameters');
else
    [feat_test , list_im_test] = matcaffe_batch_feat(test_file_list, use_gpu, feat_len, model_def_file, model_file);
    save(feat_test_file, 'feat_test', '-v7.3');
    binary_test = (feat_test>0.5);
    save(binary_test_file,'binary_test','-v7.3');
    save('file_name_test.mat','list_im_test','-v7.3')
end
    
% feature extraction- training set
if exist(binary_train_file, 'file') ~= 0
    load(binary_train_file);
else
    [feat_train , list_im_train] = matcaffe_batch_feat(train_file_list, use_gpu, feat_len, model_def_file, model_file);
    save(feat_train_file, 'feat_train', '-v7.3');
    binary_train = (feat_train>0.5);
    save(binary_train_file,'binary_train','-v7.3');
    save('file_name_train.mat','list_im_train','-v7.3')
end

trn_label = load(train_label_file);
tst_label = load(test_label_file);

[map, precision_at_k] = precision( trn_label, binary_train, tst_label, binary_test, top_k, 1);
fprintf('MAP = %f\n',map);
save(map_file, 'map', '-ascii');
P = [[1:1:top_k]' precision_at_k'];
save(precision_file, 'P', '-ascii');



