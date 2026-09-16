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
% Verification
%   Each generated .mlx is exported back to plain code and compared against
%   the source .m. The comparison ignores a blank line at the end of a code
%   section (immediately before a "%%" heading) and trailing blank lines at
%   the end of the file, because the Live Editor does not keep those. Any
%   other difference is a real one and is reported as FAIL.
%
% Notes
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

%% Regenerate and verify each one

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

    % Export straight back to plain code and compare with the source.
    fn_tmp = [tempname '.m'];
    cleanup = onCleanup(@() delete_if_present(fn_tmp));
    export(fn_mlx, fn_tmp, 'Run', false);

    src = normalize_code(fileread(fn_m));
    rt  = normalize_code(fileread(fn_tmp));
    if isequal(src, rt)
      ok   = true;
      n_ok = n_ok + 1;
    else
      note = first_difference(src, rt);
    end
    clear cleanup
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

fprintf('\n  %d of %d regenerated and verified.\n\n', n_ok, numel(fns));

if nargout > 0
  results = res;
end

end

% -------------------------------------------------------------------------

function lines = normalize_code(str)
% Split into lines and drop the whitespace the Live Editor does not keep: a
% blank line at the end of a code section and blank lines at end of file.
lines = regexp(str, '\r\n|\n|\r', 'split').';
lines = regexprep(lines, '\s+$', '');

keep = true(numel(lines),1);
for idx = 1:numel(lines)-1
  if isempty(lines{idx}) && startsWith(lines{idx+1}, '%%')
    keep(idx) = false;
  end
end
lines = lines(keep);

while ~isempty(lines) && isempty(lines{end})
  lines(end) = [];
end
end

% -------------------------------------------------------------------------

function str = first_difference(a, b)
% Report the first line that differs, so a real mismatch is easy to find.
n = min(numel(a), numel(b));
for idx = 1:n
  if ~strcmp(a{idx}, b{idx})
    str = sprintf('line %d differs: .m has "%s", .mlx has "%s"', ...
      idx, trim_to(a{idx},40), trim_to(b{idx},40));
    return
  end
end
str = sprintf('.m has %d lines, .mlx has %d', numel(a), numel(b));
end

% -------------------------------------------------------------------------

function str = trim_to(str, n)
if numel(str) > n
  str = [str(1:n) '...'];
end
end

% -------------------------------------------------------------------------

function delete_if_present(fn)
if exist(fn,'file')
  delete(fn);
end
end
