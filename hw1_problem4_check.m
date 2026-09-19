function results = hw1_problem4_check(varargin)
% results = hw1_problem4_check(...)
%
% Checks the variables that the student was asked to supply in
% hw1_problem4.m (every "% HERE" entry in hw1_problem4_template.m).
%
% Usage
%   1) Run the student's hw1_problem4.m so that its variables are left in
%      the workspace.
%   2) Call this function from that same workspace:
%        >> hw1_problem4
%        >> hw1_problem4_check
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
%   * Problem 4 starts from raw_rds.mat, which problem 3 wrote. The
%     reference values assume that file came from a CORRECT problem 3, so
%     run hw1_problem3_check first. A wrong problem 3 cascades into nearly
%     every check here.
%   * Section 3 asks for the contents of problem 3 sections 4 and 8 to be
%     copied in, so those variables are checked again here.
%   * measured_phase and kx_expected are also accepted under the names
%     "max_phase" and "target_kx", which earlier versions of the template
%     used in their section 8 and 9 comments. The report says when the alternate
%     name was found.
%   * time_pc is supplied by the template rather than asked for, so it is
%     not graded.
%   * The reference was generated with the target and system/image
%     parameters as distributed (sys_rds.yaml, img_rds.yaml, one target at
%     the scene center). Changing any of those invalidates the comparison.
%
% See also HW1_PROBLEM2_CHECK, HW1_PROBLEM3_CHECK

%% Options

opt = struct('show_expected', false, 'tol_pct', 1.0, 'tol_endpoint_pct', 10.0, ...
  'tol_dB', 0.1, 'workspace', 'caller');
valid_opts = fieldnames(opt);
if mod(numel(varargin),2) ~= 0
  error('hw1_problem4_check:badInput','Options must be name/value pairs.');
end
for arg_idx = 1:2:numel(varargin)
  if ~ismember(varargin{arg_idx}, valid_opts)
    error('hw1_problem4_check:badOption','Unknown option "%s". Valid options: %s.', ...
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
  '3',   'lambda_fc',      's', [1 1],       1.53739722051459,     0, 0, ''; ...
  '3',   'sigma_r',        's', [1 1],       2.49827048333621,     0, 0, ''; ...
  '3',   'r_ref',          's', [1 1],       707.106781186547,     0, 0, ''; ...
  '3',   't_ref',          's', [1 1],       4.71730867349394e-06, 0, 0, ''; ...
  '3',   'r0',             's', [1 1],       644.606781186547,     0, 0, ''; ...
  '3',   'r1',             's', [1 1],       769.606781186547,     0, 0, ''; ...
  '3',   'L_sar',          's', [1 1],       236.638265257076,     0, 0, ''; ...
  '3',   'df',             's', [1 1],       91743.119266055,      0, 0, ''; ...
  '3',   'freq',           'a', [3270 1],    4952272668.90222,     0,                     -91743.119266055,      ''; ...
  '3',   'range',          'a', [3270 1],    48826.4575480413,     -104.927360300121,     1528.44188170509,      ''; ...
  '3',   'eta',            'a', [1 1449],    31.8450435703894,     -1.448,                1.448,                 ''; ...
  '3',   'deta',           's', [1 1],       0.002,                0, 0, ''; ...
  '3',   'dkx',            's', [1 1],       0.0173448869763412,   0, 0, ''; ...
  '3',   'kx',             'a', [1 1449],    276.174340742532,     0,                     -0.0173448869763412,   ''; ...
  '3',   'df_eta',         's', [1 1],       0.345065562456867,    0, 0, ''; ...
  '3',   'f_eta',          'a', [1 1449],    5494.31393553993,     0,                     -0.345065562456867,    ''; ...
  '4',   'ref_fft',        'a', [3270 1],    3132.09195267316, ...
                                             86.5991636882721 + 83.4266557540899i, ...
                                             -88.6541661516194 - 87.7940740280011i, ''; ...
  '4',   'data_pc',        'a', [3270 1449], 255202.905108129, ...
                                             0.303035491074777 - 0.0793218550983355i, ...
                                             1.06468578118543 - 0.239587541938809i, ''; ...
  '4',   'range_pc',       'a', [3270 1],    48826.4575480413,     -104.927360300121,     1528.44188170509,      ''; ...
  '8',   'max_val',        'a', [1 1449],    112569.33035657, ...
                                             -2903.17732722835 + 612.988650522146i, ...
                                             -2903.17732722835 + 612.988650522146i, ''; ...
  '8',   'max_idx',        'a', [1 1449],    62487.4477475277,     1672,                  1672,                  ''; ...
  '8',   'measured_phase', 'a', [1 1449],    3190.99062458676,     -186.34623277141,      -186.34623277141,      'max_phase'; ...
  '8',   'expected_phase', 'a', [1 1449],    3190.99094606438,     -186.346249998152,     -186.346249998152,     ''; ...
  '9',   'k_fc',           's', [1 1],       8.17379558560215,     0, 0, ''; ...
  '9',   'kx_expected',    'a', [1 1449],    45.4273355960061,     2.0482880906603,       -2.0482880906603,      'target_kx'; ...
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

res = run_check(ref, opt, 'hw1 problem 4', found, used, vals);
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
