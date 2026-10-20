function results = hw5_problem1_check(varargin)
% results = hw5_problem1_check(...)
%
% Checks the variables that the student was asked to supply in
% hw5_problem1.m (every "% HERE" entry in hw5_problem1_template.m).
%
% Usage
%   1) Run the student's hw5_problem1.m so that its variables are left in
%      the workspace.
%   2) Call this function from that same workspace:
%        >> hw5_problem1
%        >> hw5_problem1_check
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
%     numerically zero (symmetric axes, data_fk); and (d) the Frobenius
%     norm of angle(v), graded as percent error ('tol_pct').
%   * No formulas are used or shown. Every reference is a plain constant, so
%     this function reveals nothing about how an answer is derived.
%
% Notes
%   * df, dkx and dt are assigned more than once (sections 3, 9 and 10).
%     Each is checked once, under section 10, since that is the value that
%     survives to the end of the script. Nt is redefined in section 9 as the
%     length of fy_out and is checked at that value.
%   * D is real with the parameters as distributed (every Doppler bin is
%     visible at every range frequency), so H_pc is the first complex
%     answer. The coherent sum of data_fk is numerically zero, so only its
%     angle norm is checked.
%   * freq_out, bin_offset and bin_frac are loop variables from section 6
%     and therefore hold the values for the LAST Doppler bin. rbin_rng holds
%     the value for the last fy_out bin of that Doppler bin, where it is the
%     full -Ninterp:Ninterp. data_stolt_fftshift is graded over every
%     element, so the per-pixel interpolation line is covered by it.
%   * time_img_Mt, range_img_Mt and x_img_Mx are from the section 13 loop
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
  error('hw5_problem1_check:badInput','Options must be name/value pairs.');
end
for arg_idx = 1:2:numel(varargin)
  if ~ismember(varargin{arg_idx}, valid_opts)
    error('hw5_problem1_check:badOption','Unknown option "%s". Valid options: %s.', ...
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
  '3',  'Kr',                  's', [1 1],        6000000000000,           0, 0, '',            [], [], [];
  '4',  'data_fk',             'a', [1309 277],    347168.421951075, ...
                                                718.580505270945 - 556.17860606775i, ...
                                                671.88245460155 - 511.478945860739i, '', [], NaN, 1091.91129800946;
  '5',  'D',                   'a', [1309 277],       591.583671152095,        1,                       0.99999753332687,        '',            [], NaN, 0;
  '5',  'H_pc',                'a', [1309 277],    602.156956282994, ...
                                                0.800993356164389 + 0.598673235897938i, ...
                                                -0.794766772087394 - 0.606914967673219i, '', [], -0.889634519162, 1091.4894289107;
  '5',  'data_pc',             'a', [1309 277],    347168.421951075, ...
                                                908.547456423061 - 15.3004519573064i, ...
                                                -844.414077558432 - 1.26904742230005i, '', [], 1.49572240619363, 1102.57546037305;
  '6',  'data_pc_fftshift',    'a', [1309 277],    347168.421951075, ...
                                                15.4619509919871 - 7.77483456118504i, ...
                                                -10.4930332594445 + 8.96683309817748i, '', [], 1.49572240619354, 1102.57546037305;
  '6',  'freq_fftshift',       'a', [1309 1],       1253315236.98934,        -59954163.4835748,       59954163.4835748,        '',            [], NaN, 80.3412800390462;
  '6',  'D_fftshift',          'a', [1309 277],       591.583671152095,        1,                       0.999998558389454,       '',            [], NaN, 0;
  '6',  'fy_fftshift',         'a', [1309 277],       117423192138.299,        135045836.516425,        254953795.938964,        '',            [], NaN, 0;
  '6',  'min_fy',              's', [1 1],        135045836.516425,        0, 0, '',            [], [], [];
  '6',  'max_fy',              's', [1 1],        247855834.58422,         0, 0, '',            [], [], [];
  '6',  'dfy',                 's', [1 1],        91673.0328494906,        0, 0, '',            [], [], [];
  '6',  'fy_out_fftshift',     'a', [1231 1],       6812816461.99915,        135045836.516425,        247803666.921299,        '',            [], NaN, 0;
  '6',  'freq_out',            'a', [1231 1],       1149835900.79998,        -59953469.5953149,       52804045.0710287,        '',            [], NaN, 80.3412800390462;
  '6',  'bin_offset',          'a', [1231 1],       24920.7876079389,        0,                       1230,                    '',            [], NaN, 0;
  '6',  'bin_frac',            'a', [1231 1],       0.196063914928234,       0.00756916443559285,     0.00412498330536716,     '',            [], NaN, 0;
  '6',  'rbin_rng',            'a', [11 1],       10.4880884817015,        -5,                      5,                       '',            [], NaN, 7.02481473104073;
  '6',  'data_stolt_fftshift', 'a', [1231 277],    348194.726951151, ...
                                                15.4619509919871 - 7.77483456118504i, ...
                                                3.51481765313247 - 2.68524659678999i, '', [], 1.60187565809385, 1069.4671942533;
  '6',  'fy_out',              'a', [1231 1],       6812816461.99915,        191424751.718862,        191333078.686012,        '',            [], NaN, 0;
  '6',  'data_stolt',          'a', [1231 277],    348194.726951151, ...
                                                838.005967855129 - 43.0777032391044i, ...
                                                -926.250525947433 - 22.0864193323729i, '', [], 1.60187565809322, 1069.4671942533;
  '7',  'B_kx',                's', [1 1],        2.51327412287183,        0, 0, '',            [], [], [];
  '7',  'H_kx',                'a', [1 277],       11.7898261225516,        1,                       1,                       '',            [], NaN, 0;
  '7',  'data_stolt_window',   'a', [1231 277],    262366.585041252, ...
                                                838.005967855129 - 43.0777032391044i, ...
                                                -926.250525947433 - 22.0864193323729i, '', [], 3.10140427135125, 594.839821521993;
  '8',  'data_img_ifftshift',  'a', [1231 277],    449.303303305456, ...
                                                -1.16527769011947 + 0.04685585366564i, ...
                                                -0.720091841640202 - 0.0188538526293291i, '', [], -0.0513598005514372, 1064.53774473097;
  '9',  'Nt',                  's', [1 1],        1231,                    0, 0, '',            [], [], [];
  '9',  'fs_y',                's', [1 1],        112849503.437723,        0, 0, '',            [], [], [];
  '9',  'time_img',            'a', [1231 1],       0.000188539076623707,    -1.09536597369627e-06,   9.80410600031012e-06,    '',            [], NaN, 34.9832952383717;
  '9',  'data_img',            'a', [1231 277],    449.303303305456, ...
                                                0.00292639087042542 + 0.00477124890208425i, ...
                                                0.00356200806252119 + 0.00493722969534681i, '', [], -0.0513598005514374, 1064.53774473097;
  '10', 'dt',                  's', [1 1],        8.8613593284609e-09,     0, 0, '',            [], [], [];
  '10', 'df',                  's', [1 1],        91673.0328494864,        0, 0, '',            [], [], [];
  '10', 'freq_img',            'a', [1231 1],       1142978108.90824,        0,                       -91673.0328494864,       '',            [], NaN, 77.9089642253698;
  '10', 'dkx',                 's', [1 1],        0.0181463835586414,      0, 0, '',            [], [], [];
  '10', 'kx_img',              'a', [1 277],       24.1499528281597,        0,                       -0.0181463835586414,     '',            [], NaN, 36.9053574342579;
  '13', 'time_img_Mt',         'a', [12310 1],       0.000596571537961609,    -1.09536597369627e-06,   9.81208122370624e-06,    '',            [], NaN, 110.492989117625;
  '13', 'range_img_Mt',        'a', [12310 1],       52370.6371928507,        -816.894873498313,       818.090329410825,        '',            [], NaN, 246.369777096744;
  '13', 'x_img_Mx',            'a', [1 2770],       5260.72853943491,        -172.5,                  173.625,                 '',            [], NaN, 116.704987354883;
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

res = run_check(ref, opt, 'hw5 problem 1', found, used, vals);
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
