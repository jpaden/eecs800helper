function results = mlx_from_m(varargin)
% results = mlx_from_m(fn1, fn2, ...)
%
% Regenerates the Live Script (.mlx) for each plain script (.m) given, so
% that the .m file is the single source of truth. Check and edit the .m
% file, then run this to bring its .mlx back into sync.
%
% Usage
%   >> mlx_from_m hw1_problem3_template.m
%   >> mlx_from_m hw1_problem2_template hw1_problem3_template
%   >> mlx_from_m(dir('hw1_problem*_template.m'))
%
% Input
%   fn   path to a .m file. The ".m" may be omitted. A struct array from
%        dir() is also accepted, so a whole set can be passed at once.
%
% Output
%   results  struct array with fields fn_m, fn_mlx, ok, note. Only returned
%            when asked for, so "ans" is not echoed.
%
% Notes
%   * The .mlx is generated from the .m and is never read back or compared,
%     so the .m file always wins. The Live Editor drops trailing blank lines
%     at the end of a code section, which means the .mlx does not always
%     reproduce the .m byte for byte. That does not matter: regenerate the
%     .mlx rather than exporting it back.
%   * This only preserves what a plain .m file can express: code, comments
%     and "%%" section headings. Live Editor extras (formatted text,
%     equations, images, embedded output) are NOT preserved, so do not
%     hand-edit the .mlx if you intend to regenerate it.
%   * matlab.internal.liveeditor.openAndSave is an undocumented function and
%     could change between releases. Verified on R2024b.

%% Collect the file list

fns = {};
for arg_idx = 1:numel(varargin)
  arg = varargin{arg_idx};
  if isstruct(arg)                       % e.g. the output of dir()
    for s_idx = 1:numel(arg)
      fns{end+1} = fullfile(arg(s_idx).folder, arg(s_idx).name); %#ok<AGROW>
    end
  elseif ischar(arg) || isstring(arg)
    fns{end+1} = char(arg); %#ok<AGROW>
  else
    error('mlx_from_m:badInput','Inputs must be file names or a dir() struct.');
  end
end
if isempty(fns)
  error('mlx_from_m:noInput','Give at least one .m file.');
end

%% Regenerate each one

res = struct('fn_m', {}, 'fn_mlx', {}, 'ok', {}, 'note', {});
n_ok = 0;

fprintf('\n');
for f_idx = 1:numel(fns)

  fn_m = fns{f_idx};
  [~,~,ext] = fileparts(fn_m);
  if isempty(ext)
    fn_m = [fn_m '.m']; %#ok<AGROW>
  elseif ~strcmpi(ext,'.m')
    error('mlx_from_m:notM','"%s" is not a .m file.', fn_m);
  end
  if ~exist(fn_m,'file')
    error('mlx_from_m:missing','"%s" does not exist.', fn_m);
  end
  fn_mlx = [fn_m(1:end-2) '.mlx'];

  note = '';
  ok   = false;
  try
    matlab.internal.liveeditor.openAndSave(fn_m, fn_mlx);
    ok   = true;
    n_ok = n_ok + 1;
  catch ME
    note = ME.message;
  end

  if ok
    fprintf('  OK    %s  ->  %s\n', fn_m, fn_mlx);
  else
    fprintf('  FAIL  %s  ->  %s\n           (%s)\n', fn_m, fn_mlx, note);
  end

  res(end+1).fn_m = fn_m; %#ok<AGROW>
  res(end).fn_mlx = fn_mlx;
  res(end).ok     = ok;
  res(end).note   = note;

end

fprintf('\n  %d of %d regenerated.\n\n', n_ok, numel(fns));

if nargout > 0
  results = res;
end

end
