function results = hw2_problem2_check(varargin)
% results = hw2_problem2_check(...)
%
% Checks the variables that the student was asked to supply in
% hw2_problem2.m (every "% HERE" entry in hw2_problem2_template.m).
%
% Usage
%   1) Run the student's hw2_problem2.m so that its variables are left in
%      the workspace.
%   2) Call this function from that same workspace:
%        >> hw2_problem2
%        >> hw2_problem2_check
%
% Options (name/value pairs)
%   'tol_pct'       percent error allowed on values and norms (default 1.0)
%   'tol_dB'        absolute error allowed on dB-valued answers (default
%                   0.1). No answer in this problem is graded in dB.
%   'tol_endpoint_pct'  percent error allowed on the first/last element of
%                   an array (default 10.0). Looser than 'tol_pct' on
%                   purpose: the endpoint test exists to catch a reversed or
%                   mis-started axis, not to re-grade the norm.
%   'show_expected' true -> also print reference values      (default false)
%                   Leave false when handing this to students so that they
%                   see how far off they are without being handed answers.
%   'workspace'     'caller' or 'base'                      (default 'caller')
%
% Output
%   results  struct array, one element per checked variable, with fields
%            section, name, kind, value, pct_err, status, note
%
% How answers are graded
%   * Scalars are compared to a stored value and reported as percent error.
%   * Vectors and matrices are compared on (a) their size, which must match
%     exactly, and (b) their Frobenius norm, reported as percent error.
%     The first and last elements are also compared, which catches a
%     reversed or mis-started axis that happens to carry the right norm.
%   * No formulas are used or shown. Every reference is a plain constant, so
%     this function reveals nothing about how an answer is derived.
%
% Notes
%   * img_pos, R, td, squint_ang, H_squint_ang, H_time, H_chirp, H_sar and
%     img_matched_filter are loop variables from section 3 and therefore hold
%     the values for the LAST image pixel.
%   * data_img is checked as the loop leaves it. sar.data_img is checked
%     after the section 6 windowing, which overwrites it.
%   * time_img_Mt, range_img_Mt and x_img_Mx are from the section 9 loop over
%     targets and hold the values for the last target.
%   * This problem runs on a quarter-size image (img.x and img.r are divided
%     by 4 in section 2). The reference assumes that, so removing the divide
%     invalidates every array size here.
%   * Run hw2_problem1 first: this problem reads the raw data it saves.
%
% See also HW2_PROBLEM1_CHECK, HW2_PROBLEM3_CHECK

%% Options

opt = struct('show_expected', false, 'tol_pct', 1.0, 'tol_endpoint_pct', 10.0, ...
  'tol_dB', 0.1, 'workspace', 'caller');
valid_opts = fieldnames(opt);
if mod(numel(varargin),2) ~= 0
  error('hw2_problem2_check:badInput','Options must be name/value pairs.');
end
for arg_idx = 1:2:numel(varargin)
  if ~ismember(varargin{arg_idx}, valid_opts)
    error('hw2_problem2_check:badOption','Unknown option "%s". Valid options: %s.', ...
      varargin{arg_idx}, strjoin(valid_opts.',', '));
  end
  opt.(varargin{arg_idx}) = varargin{arg_idx+1};
end

%% Reference answers
% Columns: {section, name, kind, size, value/norm, first element, last element, alias[, tol_pct]}
%   tol_pct (optional 9th column) overrides the 'tol_pct' option for that row;
%   leave it [] to use the option. Use it where a common mistake lands
%   inside the default tolerance.
%   kind 's' -> scalar,        value/norm is the signed value
%   kind 'a' -> vector/matrix, value/norm is the Frobenius norm

ref = { ...
  '3', 'Kr',                 's', [1 1],        6000000000000,         0, 0, '', [];
  '3', 'Nx_img',             's', [1 1],        25,                    0, 0, '', 0;
  '3', 'Nr_img',             's', [1 1],        25,                    0, 0, '', 0;
  '3', 'x_img',              'a', [1 25],       45.0693909432999,      -15,                   15,                    '', [];
  '3', 'r_img',              'a', [25 1],       45.0693909432999,      -15,                   15,                    '', [];
  '3', 'y_img',              'a', [25 1],       28.9700460744719,      9.64181414529809,      -9.64181414529809,     '', [];
  '3', 'z_img',              'a', [25 1],       34.5251564868717,      11.4906666467847,      -11.4906666467847,     '', [];
  '3', 'time_img',           'a', [25 1],       2.17739261075424e-05,  4.25430078474759e-06,  4.45443924186626e-06,  '', [];
  '3', 'img_pos',            'a', [3 1],        21.2132034355964,      15,                    -11.4906666467847,     '', [];
  '3', 'R',                  'a', [1 1037],     21745.8650813295,      693.57547165267,       686.066275864237,      '', [];
  '3', 'td',                 'a', [1 1037],     0.000145072796202928,  4.62703749306376e-06,  4.57694153108713e-06,  '', [];
  '3', 'squint_ang',         'a', [1 1037],     4.80013248844439,      0.273993979898601,     -0.231885112839585,    '', [];
  '3', 'H_squint_ang',       'a', [1 1037],     32.2024843762092,      1,                     1,                     '', [];
  '3', 'H_time',             'a', [819 1037],   853.897315255177,      0,                     0,                     '', [];
  '3', 'H_chirp',            'a', [819 1037],   921.576366884481, ...
                                                -0.0301621007403908 + 0.999545020336216i, ...
                                                0.811398525308228 + 0.584493313159041i, '', [];
  '3', 'H_sar',              'a', [1 1037],     32.2024843762092, ...
                                                -0.553431757599437 + 0.832894524943223i, ...
                                                0.762224545245219 + 0.647312708530985i, '', [];
  '3', 'img_matched_filter', 'a', [819 1037],   853.897315255178,      0,                     0,                     '', [];
  '3', 'data_img',           'a', [25 25],      1147397.50827093, ...
                                                457.223352636258 + 124.176921009645i, ...
                                                450.95933026097 - 65.7350244086607i, '', [];
  '4', 'df',                 's', [1 1],        4796679.3280054,       0, 0, '', [];
  '4', 'freq_img',           'a', [25 1],       172946732.690816,      0,                     -4796679.3280054,      '', [];
  '4', 'dkx',                's', [1 1],        0.201061929829747,     0, 0, '', [];
  '4', 'kx_img',             'a', [1 25],       7.24939097544895,      0,                     -0.201061929829747,    '', [];
  '6', 'B_kx',               's', [1 1],        2.51327412287183,      0, 0, '', [];
  '6', 'sar.data_img',       'a', [25 25],      902100.938515058, ...
                                                853.033983240916 - 1107.80062920471i, ...
                                                1009.91645151106 + 1727.99284776098i, '', [];
  '9', 'time_img_Mt',        'a', [250 1],      6.89145386115203e-05,  4.25430078474759e-06,  4.46194443400821e-06,  '', [];
  '9', 'range_img_Mt',       'a', [250 1],      142.911959349108,      -15,                   16.1250000000008,      '', [];
  '9', 'x_img_Mx',           'a', [1 250],      142.911959349104,      -15,                   16.125,                '', [];
  };

%% Snapshot the variables of interest
% This has to happen here, in the top-level function, because
% evalin('caller',...) is relative to whoever called THIS function. Doing it
% inside a local function would look at the wrong workspace. MATLAB shares
% array storage on assignment, so this does not duplicate the large arrays.

n_ref = size(ref,1);
found = false(n_ref,1);
used  = cell(n_ref,1);
vals  = cell(n_ref,1);
for idx = 1:n_ref
  for cand = ref(idx,[2 8])            % primary name first, then the alias
    nm = cand{1};
    if isempty(nm)
      continue
    end
    % A dotted name such as sys.vel is a field of a struct variable, so test
    % that the struct itself is a variable and then let the field lookup fail
    % harmlessly if the student never assigned it.
    if ~evalin(opt.workspace, sprintf('exist(''%s'',''var'')==1', strtok(nm,'.')))
      continue
    end
    try
      vals{idx} = evalin(opt.workspace, nm);
    catch
      continue
    end
    found(idx) = true;
    used{idx}  = nm;
    break
  end
end

res = run_check(ref, opt, 'hw2 problem 2', found, used, vals);
if nargout > 0
  results = res;   % only return when asked, so "ans" is not echoed
end

end

% =========================================================================
% Shared comparison engine
% This block is byte-identical in every hwN_problemM_check function. Keep it
% that way: fix a bug in one, copy it to all.
% =========================================================================

function results = run_check(ref, opt, title_str, found, used, vals)

results = struct('section', {}, 'name', {}, 'kind', {}, 'value', {}, ...
  'pct_err', {}, 'status', {}, 'note', {});
n_pass = 0;
n_fail = 0;
n_absent = 0;

fprintf('\n');
fprintf('==================================================================================\n');
fprintf(' EECS 800 %s -- answer check\n', title_str);
fprintf(' Tolerance: %.3g%% on values and norms', opt.tol_pct);
if any(strcmp(ref(:,3),'d'))
  fprintf(', %.3g dB on dB values', opt.tol_dB);
end
fprintf('.\n');
if size(ref,2) >= 9
  tight = find(~cellfun(@isempty, ref(:,9))).';
  if ~isempty(tight)
    fprintf(' Tighter tolerance on:');
    for idx = tight
      fprintf(' %s (%.3g%%)', ref{idx,2}, ref{idx,9});
    end
    fprintf('.\n');
  end
end
fprintf(' Scalars show their value; arrays show their Frobenius norm.\n');
fprintf('==================================================================================\n');
if opt.show_expected
  fprintf('%-5s %-14s %-12s %15s %15s %10s  %s\n', ...
    'Sec', 'Variable', 'Size', 'Value/Norm', 'Expected', '%Err', 'Status');
else
  fprintf('%-5s %-14s %-12s %15s %10s  %s\n', ...
    'Sec', 'Variable', 'Size', 'Value/Norm', '%Err', 'Status');
end
fprintf('----------------------------------------------------------------------------------\n');

for idx = 1:size(ref,1)

  sec    = ref{idx,1};
  name   = ref{idx,2};
  kind   = ref{idx,3};
  e_size = ref{idx,4};
  e_val  = ref{idx,5};
  e_frst = ref{idx,6};
  e_last = ref{idx,7};
  tol    = opt.tol_pct;             % per-row override in optional column 9
  if size(ref,2) >= 9 && ~isempty(ref{idx,9})
    tol = ref{idx,9};
  end

  note     = '';
  pct      = NaN;
  shown    = NaN;
  size_str = '--';
  val      = [];

  if ~found(idx)
    status   = 'MISSING';
    n_absent = n_absent + 1;

  else
    val = vals{idx};
    if ~strcmp(used{idx}, name)
      note = sprintf('found as "%s"', used{idx});
    end

    % ---- sanity checks on what the student produced ----------------------
    if ~(isnumeric(val) || islogical(val)) || isempty(val)
      status = 'INVALID';
      note   = add_note(note, 'not a non-empty numeric value');
      n_fail = n_fail + 1;

    else
      val      = double(val);
      size_str = size2str(size(val));

      if ~all(isfinite(val(:)))
        status = 'INVALID';
        note   = add_note(note, sprintf('contains %d NaN/Inf element(s)', ...
          sum(~isfinite(val(:)))));
        n_fail = n_fail + 1;

      elseif strcmp(kind,'s') || strcmp(kind,'d')
        % ---- scalar, graded linearly ('s') or in dB ('d') ------------------
        if ~isscalar(val)
          note = add_note(note, sprintf('expected a scalar, got %s; used element 1', size_str));
          val  = val(1);
        end
        if ~isreal(val)
          note = add_note(note, 'complex, used real part');
          val  = real(val);
        end
        shown = val;
        pct   = 100*abs(val - e_val)/abs(e_val);

        if strcmp(kind,'d')
          db_err = abs(val - e_val);
          ok     = db_err <= opt.tol_dB;
        else
          db_err = NaN;
          ok     = pct <= tol;
        end

        if ok
          status = 'PASS';
          n_pass = n_pass + 1;
        else
          status = 'FAIL';
          n_fail = n_fail + 1;
          if strcmp(kind,'d')
            note = add_note(note, sprintf('off by %.4g dB', db_err));
          else
            note = add_note(note, ratio_hint(val, e_val, tol));
          end
        end

      else
        % ---- vector / matrix -----------------------------------------------
        fro   = norm(val(:));
        shown = fro;
        pct   = 100*abs(fro - e_val)/abs(e_val);
        ok    = true;

        if ~isequal(size(val), e_size)
          ok = false;
          if isequal(size(val), fliplr(e_size))
            note = add_note(note, 'size mismatch: it is transposed');
          elseif opt.show_expected
            note = add_note(note, sprintf('size mismatch: expected %s', size2str(e_size)));
          else
            note = add_note(note, 'size mismatch');
          end
        end

        if pct > tol
          ok   = false;
          note = add_note(note, ['norm ' ratio_hint(fro, e_val, tol)]);
        end

        % endpoints catch a reversed or mis-started axis with the right norm
        if isequal(size(val), e_size)
          [ok_f, pct_f] = endpoint_ok(val(1),   e_frst, e_val, opt.tol_endpoint_pct);
          [ok_l, pct_l] = endpoint_ok(val(end), e_last, e_val, opt.tol_endpoint_pct);
          if ~ok_f
            ok   = false;
            note = add_note(note, endpoint_note('first', pct_f));
          end
          if ~ok_l
            ok   = false;
            note = add_note(note, endpoint_note('last', pct_l));
          end
          if ~ok_f && ~ok_l && pct <= tol
            note = add_note(note, 'norm is right, so check order/orientation');
          end
        end

        if ok
          status = 'PASS';
          n_pass = n_pass + 1;
        else
          status = 'FAIL';
          n_fail = n_fail + 1;
        end
      end
    end
  end

  print_row(opt, sec, name, size_str, shown, e_val, pct, status, note);

  results(end+1).section = sec; %#ok<AGROW>
  results(end).name      = name;
  results(end).kind      = kind;
  results(end).value     = shown;
  results(end).pct_err   = pct;
  results(end).status    = status;
  results(end).note      = note;

end

n_total = size(ref,1);
fprintf('----------------------------------------------------------------------------------\n');
fprintf(' Passed %d of %d   (failed %d, missing %d)   score %.1f%%\n', ...
  n_pass, n_total, n_fail, n_absent, 100*n_pass/n_total);
fprintf('==================================================================================\n');
if n_pass < n_total
  bad = unique({results(~strcmp({results.status},'PASS')).section});
  fprintf(' Sections still needing work:');
  fprintf(' %s', bad{:});
  fprintf('\n\n');
else
  fprintf(' All answers are within tolerance.\n\n');
end

end

% -------------------------------------------------------------------------

function [ok, pct] = endpoint_ok(v, e, fro_ref, tol_pct)
% Compare one endpoint. When the reference endpoint is (numerically) zero a
% percent error is meaningless, so require the student's to be small too.
if abs(e) > 1e-9*abs(fro_ref)
  pct = 100*abs(v - e)/abs(e);
  ok  = pct <= tol_pct;
else
  pct = NaN;
  ok  = abs(v) <= 1e-6*abs(fro_ref);
end
end

% -------------------------------------------------------------------------

function str = endpoint_note(which_end, pct)
if isnan(pct)
  str = sprintf('%s element should be zero', which_end);
else
  str = sprintf('%s element off by %.4g%%', which_end, pct);
end
end

% -------------------------------------------------------------------------

function str = ratio_hint(v, e, tol_pct)
% Formula-free diagnostic: a sign flip, or the plain ratio.
if 100*abs(v + e)/abs(e) <= tol_pct
  str = 'sign is flipped';
else
  str = sprintf('student/expected = %.6g', v/e);
end
end

% -------------------------------------------------------------------------

function note = add_note(note, str)
if isempty(note)
  note = str;
else
  note = [note '; ' str];
end
end

% -------------------------------------------------------------------------

function str = size2str(sz)
str = strjoin(arrayfun(@(x) sprintf('%d',x), sz, 'UniformOutput', false), 'x');
end

% -------------------------------------------------------------------------

function print_row(opt, sec, name, size_str, shown, expected, pct, status, note)
if isnan(shown)
  val_str = '--';
else
  val_str = sprintf('%.6g', shown);
end
if isnan(pct)
  pct_str = '--';
else
  pct_str = sprintf('%.4g', pct);
end
if opt.show_expected
  fprintf('%-5s %-14s %-12s %15s %15s %10s  %s', sec, name, size_str, val_str, ...
    sprintf('%.6g', expected), pct_str, status);
else
  fprintf('%-5s %-14s %-12s %15s %10s  %s', sec, name, size_str, val_str, pct_str, status);
end
if ~isempty(note)
  fprintf('  (%s)', note);
end
fprintf('\n');
end
