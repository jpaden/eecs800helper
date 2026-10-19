function results = hw4_problem1_check(varargin)
% results = hw4_problem1_check(...)
%
% Checks the variables that the student was asked to supply in
% hw4_problem1.m (every "% HERE" entry in hw4_problem1_template.m).
%
% Usage
%   1) Run the student's hw4_problem1.m so that its variables are left in
%      the workspace.
%   2) Call this function from that same workspace:
%        >> hw4_problem1
%        >> hw4_problem1_check
%
% Options (name/value pairs)
%   'tol_pct'       percent error allowed on values and norms (default 1.0)
%   'tol_dB'        absolute error allowed on dB-valued answers (default
%                   0.1). No answer in this problem is graded in dB.
%   'tol_endpoint_pct'  percent error allowed on the first/last element of
%                   an array (default 10.0). Looser than 'tol_pct' on
%                   purpose: the endpoint test exists to catch a reversed or
%                   mis-started axis, not to re-grade the norm.
%   'tol_phase_deg' absolute error allowed, in degrees, on the phase of an
%                   array's coherent sum (default 0.5). See below.
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
%   * Vectors and matrices also get two phase checks, because a conjugated
%     array or a sign error in an exponent leaves the norm untouched and, for
%     arrays whose endpoints are zero, the endpoints too: (c) the phase of
%     the coherent sum, sum(v(:)), graded on absolute wrapped error in
%     degrees ('tol_phase_deg'), skipped for real arrays and where the sum is
%     numerically zero (symmetric axes, data_cs_fft); and (d) the Frobenius
%     norm of angle(v), graded as percent error ('tol_pct').
%   * No formulas are used or shown. Every reference is a plain constant, so
%     this function reveals nothing about how an answer is derived.
%
% Notes
%   * df and dkx are assigned in section 3 and again in section 11. They are
%     checked once, under section 11, since that is the value that survives
%     to the end of the script.
%   * D, Km and Km_ref are real with the parameters as distributed (every
%     Doppler bin is visible). D_ref is evaluated at the zero Doppler bin,
%     so its value is 1.
%   * The first and last elements of data_afft and data_cs are zero (the
%     first and last range bins hold no signal), so those endpoints are
%     checked as "should be zero". The coherent sum of data_cs_fft is
%     numerically zero for the same reason, so only its angle norm is
%     checked.
%   * time_img_Mt, range_img_Mt and x_img_Mx are from the section 14 loop
%     over targets and hold the values for the last target.
%   * Run hw3_problem1 first: this problem reads the raw data it saves.
%   * The reference was generated with the system/image parameters as
%     distributed (sys_rds_hw3.yaml, img_rds_hw3.yaml). Changing any of those
%     invalidates the comparison.
%
% See also HW3_PROBLEM1_CHECK, HW3_PROBLEM2_CHECK

%% Options

opt = struct('show_expected', false, 'tol_pct', 1.0, 'tol_endpoint_pct', 10.0, ...
  'tol_dB', 0.1, 'tol_phase_deg', 0.5, 'workspace', 'caller');
valid_opts = fieldnames(opt);
if mod(numel(varargin),2) ~= 0
  error('hw4_problem1_check:badInput','Options must be name/value pairs.');
end
for arg_idx = 1:2:numel(varargin)
  if ~ismember(varargin{arg_idx}, valid_opts)
    error('hw4_problem1_check:badOption','Unknown option "%s". Valid options: %s.', ...
      varargin{arg_idx}, strjoin(valid_opts.',', '));
  end
  opt.(varargin{arg_idx}) = varargin{arg_idx+1};
end

%% Reference answers
% Columns: {section, name, kind, size, value/norm, first element, last element, alias, tol_pct, phase, angle_norm}
%   tol_pct (optional 9th column) overrides the 'tol_pct' option for that row;
%   leave it [] to use the option. Use it where a common mistake lands
%   inside the default tolerance.
%   phase (10th column) is angle(sum(v(:))) in radians for a complex array,
%   NaN for a real array or where the sum is ~0 (that test is then skipped),
%   and [] for a scalar. angle_norm (11th column) is norm(angle(v(:))) for
%   an array and [] for a scalar. Both are plain constants like every other
%   column.
%   kind 's' -> scalar,        value/norm is the signed value
%   kind 'a' -> vector/matrix, value/norm is the Frobenius norm

ref = { ...
  '3',  'r_ref',               's', [1 1],        652.703644666139,        0, 0, '',            [], [], [];
  '3',  't_ref',               's', [1 1],        4.35437001330692e-06,    0, 0, '',            [], [], [];
  '3',  'freq',                'a', [1309 1],       1253315236.98934,        0,                       -91673.0328495028,       '',            [], NaN, 80.3412800390462;
  '3',  'kx',                  'a', [1 277],       24.1499528281597,        0,                       -0.0181463835586414,     '',            [], NaN, 36.9053574342579;
  '3',  'deta',                's', [1 1],        0.01,                    0, 0, '',            [], [], [];
  '3',  'df_eta',              's', [1 1],        0.36101083032491,        0, 0, '',            [], [], [];
  '3',  'f_eta',               'a', [1 277],       480.448046004714,        0,                       -0.36101083032491,       '',            [], NaN, 36.9053574342579;
  '3',  'time_pc',             'a', [1309 1],       0.000195270644448502,    -1.06666666666667e-06,   9.83333333333333e-06,    '',            [], NaN, 35.5430635052669;
  '3',  'range_pc',            'a', [1309 1],       29270.333237264,         -159.889310933517,       1473.97958516836,        '',            [], NaN, 35.5430635052669;
  '3',  'Kr',                  's', [1 1],        6000000000000,           0, 0, '',            [], [], [];
  '4',  'data_afft',           'a', [1309 277],    9595.56147393158, ...
                                                0, ...
                                                0, '', [], -0.838792749854003, 1053.56545851272;
  '5',  'D',                   'a', [1 277],       16.3789678322075,        1,                       0.999997535645583,       '',            [], NaN, 0;
  '5',  'D_ref',               's', [1 1],        1,                       0, 0, '',            [], [], [];
  '5',  'Km',                  'a', [1309 277],       3.63002330680491e+15,    6000000000000,           6000008947570.66,        '',            [], NaN, 0;
  '5',  'data_cs',             'a', [1309 277],    9595.56147393158, ...
                                                0, ...
                                                0, '', [], -0.838511137927366, 1053.35646776068;
  '6',  'data_cs_fft',         'a', [1309 277],    347168.421951075, ...
                                                718.580505270945 - 556.17860606775i, ...
                                                671.875633975945 - 511.449868213794i, '', [], NaN, 1091.61905465455;
  '7',  'Km_ref',              'a', [1 277],       100325668598932,         6000000000000,           6000003962135.69,        '',            [], NaN, 0;
  '7',  'data_pc_fk',          'a', [1309 277],    344855.932949267, ...
                                                718.580505270945 - 556.17860606775i, ...
                                                674.116502623325 - 508.492650996436i, '', [], 0.0910877210286517, 772.492791757511;
  '8',  'data_pc',             'a', [1309 277],    9531.64543499595, ...
                                                0.188969047894997 + 0.393392470701028i, ...
                                                -0.466109664666609 - 0.0509993294917772i, '', [], -0.838511137927365, 1093.28823531247;
  '9',  'B_kx',                's', [1 1],        2.51327412287183,        0, 0, '',            [], [], [];
  '9',  'H_kx',                'a', [1 277],       11.7898261225516,        1,                       1,                       '',            [], NaN, 0;
  '9',  'data_img_afft',       'a', [1309 277],    7372.26682254837, ...
                                                0.188969047894997 + 0.393392470701028i, ...
                                                -0.467469546603656 - 0.0364879994299673i, '', [], -1.96083163450894, 773.497586136222;
  '10', 'data_img',            'a', [1309 277],    442.956583275742, ...
                                                -0.00793043573693717 - 0.0011057782095036i, ...
                                                0.00046530560296133 + 0.00176073152244576i, '', [], -0.658682655712101, 1094.04882041094;
  '11', 'df',                  's', [1 1],        91673.0328495028,        0, 0, '',            [], [], [];
  '11', 'freq_img',            'a', [1309 1],       1253315236.98934,        0,                       -91673.0328495028,       '',            [], NaN, 80.3412800390462;
  '11', 'dkx',                 's', [1 1],        0.0181463835586414,      0, 0, '',            [], [], [];
  '11', 'kx_img',              'a', [1 277],       24.1499528281597,        0,                       -0.0181463835586414,     '',            [], NaN, 36.9053574342579;
  '14', 'time_img_Mt',         'a', [13090 1],       0.000617848556408653,    -1.06666666666667e-06,   9.84083333333341e-06,    '',            [], NaN, 112.397035696652;
  '14', 'range_img_Mt',        'a', [13090 1],       54007.209794056,         -812.592955599657,       822.400162219738,        '',            [], NaN, 253.400170152838;
  '14', 'x_img_Mx',            'a', [1 2770],       5260.72853943491,        -172.5,                  173.625,                 '',            [], NaN, 116.704987354883;
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

res = run_check(ref, opt, 'hw4 problem 1', found, used, vals);
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
  'pct_err', {}, 'phase_err_deg', {}, 'angle_norm_pct', {}, 'status', {}, 'note', {});
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
if size(ref,2) >= 10 && any(cellfun(@(c) ~isempty(c) && ~isnan(c), ref(:,10)))
  fprintf(', %.3g deg on the phase of an array''s sum', opt.tol_phase_deg);
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
  ph_err   = NaN;
  an_pct   = NaN;
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

        % phase of the coherent sum catches a conjugated array or a sign
        % error in an exponent, which leave the norm (and zero endpoints)
        % untouched. Skipped (NaN) where the reference sum is numerically
        % zero, e.g. a symmetric axis, or for a real-valued array.
        if size(ref,2) >= 10 && ~isempty(ref{idx,10}) && ~isnan(ref{idx,10})
          e_ph  = ref{idx,10};
          v_sum = sum(val(:));
          if abs(v_sum) <= 1e-9*sqrt(numel(val))*fro
            ok   = false;
            note = add_note(note, 'coherent sum is ~0 so its phase is undefined');
          else
            ph_err = wrap_deg(180/pi*(angle(v_sum) - e_ph));
            if abs(ph_err) > opt.tol_phase_deg
              ok   = false;
              note = add_note(note, sprintf('phase of sum off by %.4g deg', ph_err));
              if abs(wrap_deg(180/pi*(-angle(v_sum) - e_ph))) <= opt.tol_phase_deg
                note = add_note(note, 'looks conjugated');
              end
            end
          end
        end

        % norm of the element phases: a second phase statistic that does
        % not depend on the sum being well conditioned. A reference of zero
        % means every element is real and non-negative.
        if size(ref,2) >= 11 && ~isempty(ref{idx,11})
          e_an = ref{idx,11};
          an   = norm(angle(val(:)));
          if abs(e_an) > 1e-9
            an_pct = 100*abs(an - e_an)/abs(e_an);
            an_ok  = an_pct <= tol;
          else
            an_ok  = an <= 1e-6;
          end
          if ~an_ok
            ok = false;
            if abs(e_an) > 1e-9
              note = add_note(note, sprintf('angle norm off by %.4g%%', an_pct));
            else
              note = add_note(note, 'angle norm should be zero (all elements real and non-negative)');
            end
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
  results(end).phase_err_deg  = ph_err;
  results(end).angle_norm_pct = an_pct;
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

function d = wrap_deg(d)
% Wrap a difference in degrees to (-180, 180].
d = mod(d + 180, 360) - 180;
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
