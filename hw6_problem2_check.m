function results = hw6_problem2_check(varargin)
% results = hw6_problem2_check(...)
%
% Checks the variables that the student was asked to supply in
% hw6_problem2.m (every "% HERE" entry in hw6_problem2_template.m).
%
% Usage
%   1) Run the student's hw6_problem2.m so that its variables are left in
%      the workspace.
%   2) Call this function from that same workspace:
%        >> hw6_problem2
%        >> hw6_problem2_check
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
%   * dx and dkx are assigned more than once. dx is checked under section
%     6, where it is derived from BW_kx; the section 7 redefinition from
%     sar.x_img returns the same value. dkx is checked under section 7, the
%     value that survives to the end of the script; the Step 2 value is
%     covered by BW_kx = Nx_image*dkx.
%   * bin_exact, bin_offset, bin_frac and bin_rng are loop variables shared
%     by both interpolation loops, so they hold the values for the LAST row
%     and column of the Step 2 (kx) loop, where bin_rng is shortened to 9
%     elements by the edge of the data. dky_rline and dkx_rbin hold the
%     values for the last column and the last row respectively.
%     data_ky_fftshift and data_kx_fftshift are graded over every element,
%     so the per-pixel interpolation lines are covered by them.
%   * kx_c is numerically zero with the parameters as distributed (the
%     aperture is symmetric about the scene center) and so cannot be graded
%     as a percent error; it is left out. ky_c is checked.
%   * dky, BW_ky and dy are negative because ky decreases down each column
%     of the raw data. The signs are part of the reference.
%   * With only the scene-center target enabled the raw data is real, so
%     the coherent-sum phase of every array through data_window is zero and
%     their angle norms must be zero. data_img is the first answer with a
%     non-trivial angle norm.
%   * time_img_Mt, range_img_Mt and x_img_Mx are from the section 10 loop
%     over targets and hold the values for the last target.
%   * Run hw6_problem1 first: this problem reads the raw data it saves.
%   * The reference was generated with the system/image parameters as
%     distributed (sys_snow_hw6.yaml, img_snow_hw6.yaml) and with the
%     targets as distributed. Changing any of those invalidates the
%     comparison.
%
% See also HW6_PROBLEM1_CHECK

%% Options

opt = struct('show_expected', false, 'tol_pct', 1.0, 'tol_endpoint_pct', 10.0, ...
  'tol_dB', 0.1, 'tol_phase_deg', 0.5, 'workspace', 'caller');
valid_opts = fieldnames(opt);
if mod(numel(varargin),2) ~= 0
  error('hw6_problem2_check:badInput','Options must be name/value pairs.');
end
for arg_idx = 1:2:numel(varargin)
  if ~ismember(varargin{arg_idx}, valid_opts)
    error('hw6_problem2_check:badOption','Unknown option "%s". Valid options: %s.', ...
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
  '3', 'Kr', 's', [1 1], 2000000000000, 0, 0, '', [], [], [];
  '4', 'elev_ang_c', 'a', [1 141], 6.2173909778084, 0.523598775598299, 0.523598775598299, '', [], NaN, 0;
  '4', 'squint_ang_c', 'a', [1 141], 0.189012230098695, 0.0273727453887679, -0.0273727453887679, '', [], NaN, 26.2844499291169;
  '4', 'freq_rf', 'a', [137 141], 1390087432694.61, 9749174952.10786, 10251978097.0048, '', [], NaN, 0;
  '4', 'k_fc', 'a', [137 141], 58268.1565177447, 408.655195829755, 429.731145194811, '', [], NaN, 0;
  '4', 'kx', 'a', [137 141], 927.423899769047, 11.1846177939513, -11.7614523495825, '', [], NaN, 307.651598738649;
  '4', 'ky', 'a', [137 141], 58260.7753886483, -408.502109423512, -429.570163522878, '', [], NaN, 436.636173737178;
  '4', 'start_ky', 's', [1 1], -408.656405898787, 0, 0, '', [], [], [];
  '4', 'stop_ky', 's', [1 1], -429.570163522878, 0, 0, '', [], [], [];
  '4', 'dky', 's', [1 1], -0.154912162495293, 0, 0, '', [], [], [];
  '4', 'ky_out_fftshift', 'a', [136 1], 4888.16976564251, -408.656405898787, -429.569547835652, '', [], NaN, 36.636951272563;
  '4', 'kx_ky_out_fftshift', 'a', [136 141], 924.064333893172, 11.1888423672475, -11.7614354923224, '', [], NaN, 306.526726238302;
  '4', 'dky_rline', 's', [1 1], -0.154912162495293, 0, 0, '', [], [], [];
  '4', 'data_ky_fftshift', 'a', [136 141], 137.697522512807, ...
    0.997198413368126 - 1.28582105667344e-19i, ...
    0.00280108075985822 + 9.61823640222655e-20i, '', [], 1.61916769140582e-19, 7.43520816255514e-15;
  '5', 'start_kx', 's', [1 1], -11.1888423672475, 0, 0, '', [], [], [];
  '5', 'stop_kx', 's', [1 1], 11.1888423672475, 0, 0, '', [], [], [];
  '5', 'kx_out_fftshift', 'a', [1 141], 77.2528016850501, -11.1888423672475, 11.1888423672474, '', [], NaN, 26.4715302254581;
  '5', 'Nx_image', 's', [1 1], 141, 0, 0, '', [], [], [];
  '5', 'dkx_rbin', 's', [1 1], -0.168020507033177, 0, 0, '', [], [], [];
  '5', 'bin_exact', 's', [1 1], 4.40787642642887, 0, 0, '', [], [], [];
  '5', 'bin_offset', 's', [1 1], 4, 0, 0, '', [], [], [];
  '5', 'bin_frac', 's', [1 1], 0.407876426428865, 0, 0, '', [], [], [];
  '5', 'bin_rng', 'a', [1 9], 8.30662386291807, -3, 5, '', [], NaN, 5.44139809270265;
  '5', 'data_kx_fftshift', 'a', [136 141], 137.386463456459, ...
    0.997198413367618 - 1.28582105732975e-19i, ...
    0.081825350629683 + 4.81129779294454e-18i, '', [], 5.19569167760345e-20, 7.2593487654036e-15;
  '6', 'BW_kx', 's', [1 1], 22.5375253397414, 0, 0, '', [], [], [];
  '6', 'BW_ky', 's', [1 1], -21.0680540993599, 0, 0, '', [], [], [];
  '6', 'data_kx', 'a', [136 141], 137.386463456459, ...
    0.999979214973026 - 3.17763391518012e-18i, ...
    0.999960486240622 + 5.04288243898183e-17i, '', [], 5.19569167760311e-20, 7.2593487654036e-15;
  '6', 'ky_c', 's', [1 1], -419.190432948467, 0, 0, '', [], [], [];
  '6', 'data_window', 'a', [136 141], 132.300802804704, ...
    0.999979214973026 - 3.17763391518012e-18i, ...
    0.999960486240622 + 5.04288243898183e-17i, '', [], -1.057967554924e-19, 6.92512698012632e-15;
  '6', 'data_img', 'a', [136 141], 0.955396110702951, ...
    1.63061837209229e-06 - 5.06598421071014e-18i, ...
    -1.61196943230925e-06 + 6.0619654941725e-07i, '', [], 2.38849620896686e-16, 259.516514831003;
  '6', 'dx', 's', [1 1], 0.278787720145129, 0, 0, '', [], [], [];
  '6', 'dy', 's', [1 1], -0.298232825753494, 0, 0, '', [], [], [];
  '6', 'x', 'a', [1 141], 134.741309465137, -19.5151404101591, 19.5151404101591, '', [], NaN, 26.2844499291169;
  '6', 'y', 'a', [136 1], 136.551558803321, 20.2798321512376, -19.9815993254841, '', [], NaN, 25.7150441351553;
  '6', 'sar_phase_center', 'a', [3 1], 5773.50269189626, -2.41886888769396e-15, 5000, '', [], NaN, 3.14159265358979;
  '6', 't_ref', 's', [1 1], 3.85166640308851e-05, 0, 0, '', [], [], [];
  '6', 'time_img', 'a', [136 1], 0.000449166952636767, 3.83813715536393e-05, 3.86499669128772e-05, '', [], NaN, 0;
  '7', 'df', 's', [1 1], 3695696.9831559, 0, 0, '', [], [], [];
  '7', 'freq_img', 'a', [136 1], 1692144996.57993, 0, -3695696.9831559, '', [], NaN, 25.9062366868304;
  '7', 'dkx', 's', [1 1], 0.159840605246393, 0, 0, '', [], [], [];
  '7', 'kx_img', 'a', [1 141], 77.2528016850504, 0, -0.159840605246393, '', [], NaN, 26.2844499291169;
  '10', 'time_img_Mt', 'a', [2720 1], 0.00200878496698771, 3.83813715536393e-05, 3.86518570283676e-05, '', [], NaN, 0;
  '10', 'range_img_Mt', 'a', [2720 1], 610.644204335373, -20.2798321512382, 20.2649205098678, '', [], NaN, 115.898798914754;
  '10', 'x_img_Mx', 'a', [1 2820], 602.637603080134, -19.5151404101591, 19.7799887442968, '', [], NaN, 117.589607389115;
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

res = run_check(ref, opt, 'hw6 problem 2', found, used, vals);
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
