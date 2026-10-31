function results = hw6_problem1_check(varargin)
% results = hw6_problem1_check(...)
%
% Checks the variables that the student was asked to supply in
% hw6_problem1.m (every "% HERE" entry in hw6_problem1_template.m).
%
% Usage
%   1) Run the student's hw6_problem1.m so that its variables are left in
%      the workspace.
%   2) Call this function from that same workspace:
%        >> hw6_problem1
%        >> hw6_problem1_check
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
%     numerically zero (symmetric axes); and (d) the Frobenius norm of
%     angle(v), graded as percent error ('tol_pct').
%   * No formulas are used or shown. Every reference is a plain constant, so
%     this function reveals nothing about how an answer is derived.
%
% Notes
%   * x is assigned twice: in section 6 as the 1 m axis used to size the
%     PRF, then in section 8 as the radar positions. It is checked once,
%     under section 8, since that is the value that survives to the end of
%     the script. The section 6 axis is covered by theta_corner, theta_c,
%     kx_corner and B_kx, which are computed from it.
%   * t0 and t1 are assigned twice in section 7, before and after rounding
%     to a multiple of dt. Each is checked once at its final, rounded value.
%     tg_t0 and tg_t1 cover the unrounded propagation times.
%   * sys.f_prf and sys.fs are fields of the sys structure and are read as
%     such; the placeholders loaded from sys_snow_hw6.yaml must have been
%     overwritten.
%   * R, td, elev_ang, squint_ang and data are from the section 11 loop
%     over targets and hold the values for the LAST target. With the
%     targets as distributed (only the scene-center target enabled) the
%     target delay equals the deramp delay for every pulse, so every phase
%     term cancels and data is real and non-negative. The data row therefore
%     grades the beam-pattern and pulse envelopes, not the phase; enable a
%     corner target in section 5 to exercise the phase terms visually.
%   * The reference was generated with the system/image parameters as
%     distributed (sys_snow_hw6.yaml, img_snow_hw6.yaml) and with the
%     targets as distributed. Changing any of those invalidates the
%     comparison.
%
% See also HW6_PROBLEM2_CHECK

%% Options

opt = struct('show_expected', false, 'tol_pct', 1.0, 'tol_endpoint_pct', 10.0, ...
  'tol_dB', 0.1, 'tol_phase_deg', 0.5, 'workspace', 'caller');
valid_opts = fieldnames(opt);
if mod(numel(varargin),2) ~= 0
  error('hw6_problem1_check:badInput','Options must be name/value pairs.');
end
for arg_idx = 1:2:numel(varargin)
  if ~ismember(varargin{arg_idx}, valid_opts)
    error('hw6_problem1_check:badOption','Unknown option "%s". Valid options: %s.', ...
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
  '4', 'lambda_fc', 's', [1 1], 0.0299792458000345, 0, 0, '', [], [], [];
  '4', 'r_ref', 's', [1 1], 5773.50269189626, 0, 0, '', [], [], [];
  '4', 't_ref', 's', [1 1], 3.85166640308851e-05, 0, 0, '', [], [], [];
  '4', 'r0', 's', [1 1], 5761.05269189626, 0, 0, '', [], [], [];
  '4', 'r1', 's', [1 1], 5785.95269189626, 0, 0, '', [], [], [];
  '4', 'L_sar', 's', [1 1], 289.097496562882, 0, 0, '', [], [], [];
  '6', 'theta_corner', 'a', [4 314], 0.561556095826496, 0.0250854200221485, -0.0248052163318791, '', [], NaN, 78.6026230801615;
  '6', 'theta_c', 'a', [1 314], 0.278166375747626, 0.0271862811560863, -0.0270136365374406, '', [], NaN, 39.3640431227666;
  '6', 'k_fc', 's', [1 1], 419.169004389854, 0, 0, '', [], [], [];
  '6', 'kx_corner', 'a', [4 314], 235.368755344379, 10.5139277566644, -10.3965115968587, '', [], NaN, 78.6026230801615;
  '6', 'B_kx', 'a', [1 314], 32.4613556938483, 1.8548997060337, 1.85461375970849, '', [], NaN, 0;
  '6', 'B_kx_max', 's', [1 1], 1.8548997060337, 0, 0, '', [], [], [];
  '6', 'dx_max', 's', [1 1], 3.38734503366481, 0, 0, '', [], [], [];
  '6', 'sys.f_prf', 's', [1 1], 55.3530857165564, 0, 0, '', [], [], [];
  '7', 't0', 's', [1 1], -8.68814257726406e-05, 0, 0, '', [], [], [];
  '7', 't1', 's', [1 1], 0.000164520146675851, 0, 0, '', [], [], [];
  '7', 'tg_t0', 's', [1 1], 3.84336065711808e-05, 0, 0, '', [], [], [];
  '7', 'tg_t1', 's', [1 1], 3.86139289649185e-05, 0, 0, '', [], [], [];
  '7', 'Kr', 's', [1 1], 2000000000000, 0, 0, '', [], [], [];
  '7', 'sys.fs', 's', [1 1], 540967.181213094, 0, 0, '', [], [], [];
  '7', 'dt', 's', [1 1], 1.84854097388597e-06, 0, 0, '', [], [], [];
  '7', 'time', 'a', [137 1], 0.000968827713611446, -8.68814257726406e-05, 0.000164520146675851, '', [], NaN, 21.537674128169;
  '7', 'Nt', 's', [1 1], 137, 0, 0, '', [], [], [];
  '8', 'dx', 's', [1 1], 2.25823002244321, 0, 0, '', [], [], [];
  '8', 'x', 'a', [1 141], 1091.42852539949, -158.076101571025, 158.076101571025, '', [], NaN, 26.2844499291169;
  '8', 'Nx', 's', [1 1], 141, 0, 0, '', [], [], [];
  '8', 'y', 'a', [1 141], 34278.2730020052, 2886.75134594813, 2886.75134594813, '', [], NaN, 0;
  '8', 'z', 'a', [1 141], 59371.7104351896, 5000, 5000, '', [], NaN, 0;
  '9', 'eta', 'a', [1 141], 8.73142820319588, -1.2646088125682, 1.2646088125682, '', [], NaN, 26.2844499291169;
  '10', 'ref', 'a', [137 1], 11.6189500386223, ...
    0 + 0i, ...
    0 + 0i, '', [], 0.581422588156047, 20.2421327267465;
  '11', 'Rc', 'a', [1 141], 68565.2332908308, 5775.66631543247, 5775.66631543247, '', [], NaN, 0;
  '11', 'td_c', 'a', [1 141], 0.000457418000093597, 3.85310981734291e-05, 3.85310981734291e-05, '', [], NaN, 0;
  '11', 'elev_ang_c', 'a', [1 141], 6.2173909778084, 0.523598775598299, 0.523598775598299, '', [], NaN, 0;
  '11', 'squint_ang_c', 'a', [1 141], 0.189012230098695, 0.0273727453887679, -0.0273727453887679, '', [], NaN, 26.2844499291169;
  '11', 'kx', 'a', [1 141], 79.2220473348048, 11.4723736612534, -11.4723736612534, '', [], NaN, 26.2844499291169;
  '11', 'R', 'a', [1 141], 68565.2332908308, 5775.66631543247, 5775.66631543247, '', [], NaN, 0;
  '11', 'td', 'a', [1 141], 0.000457418000093597, 3.85310981734291e-05, 3.85310981734291e-05, '', [], NaN, 0;
  '11', 'elev_ang', 'a', [1 141], 6.2173909778084, 0.523598775598299, 0.523598775598299, '', [], NaN, 0;
  '11', 'squint_ang', 'a', [1 141], 0.189012230098695, 0.0273727453887679, -0.0273727453887679, '', [], NaN, 26.2844499291169;
  '11', 'data', 'a', [137 141], 137.967387450803, ...
    0 + 0i, ...
    0 + 0i, '', [], 1.65398501632363e-19, 7.50855515458648e-15;
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

res = run_check(ref, opt, 'hw6 problem 1', found, used, vals);
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
