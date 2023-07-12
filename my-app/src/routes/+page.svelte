<!-- https://daisyui.com/components/input-group/#group-label-and-text-input-horizontally -->
<div class="form-control">
	<label class="label">
		<span class="label-text">Your Email</span>
	</label>
	<label class="input-group">
		<span>Email</span>
		<input type="text" placeholder="info@site.com" class="input input-bordered" />
	</label>
</div>

<br />

<!-- https://daisyui.com/components/input-group/#group-text-input-and-button -->
<div class="form-control">
	<div class="input-group">
		<input type="text" placeholder="Search…" class="input input-bordered" />
		<button class="btn btn-square">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				class="h-6 w-6"
				fill="none"
				viewBox="0 0 24 24"
				stroke="currentColor"
				><path
					stroke-linecap="round"
					stroke-linejoin="round"
					stroke-width="2"
					d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
				/></svg
			>
		</button>
	</div>
</div>

<br />

<!-- https://daisyui.com/components/alert/#warning-color -->
<div class="alert alert-warning shadow-lg">
	<div>
		<svg
			xmlns="http://www.w3.org/2000/svg"
			class="stroke-current flex-shrink-0 h-6 w-6"
			fill="none"
			viewBox="0 0 24 24"
			><path
				stroke-linecap="round"
				stroke-linejoin="round"
				stroke-width="2"
				d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
			/></svg
		>
		<span>Warning: Invalid email address!</span>
	</div>
</div>

<br />

<!-- https://daisyui.com/components/badge/#badge-in-a-button -->
<button class="btn gap-2">
	Inbox
	<div class="badge">+99</div>
</button>
<button class="btn gap-2">
	Inbox
	<div class="badge badge-secondary">+99</div>
</button>

<br />
<br />

<!-- https://daisyui.com/components/rating/#mask-star-2-with-green-500-color -->
<div class="rating">
	<input type="radio" name="rating-4" class="mask mask-star-2 bg-green-500" />
	<input type="radio" name="rating-4" class="mask mask-star-2 bg-green-500" checked />
	<input type="radio" name="rating-4" class="mask mask-star-2 bg-green-500" />
	<input type="radio" name="rating-4" class="mask mask-star-2 bg-green-500" />
	<input type="radio" name="rating-4" class="mask mask-star-2 bg-green-500" />
</div>

<br />

<!-- https://daisyui.com/components/mockup-code/#multi-line -->
<div class="mockup-code">
	<pre data-prefix="$"><code>npm i daisyui</code></pre>
	<pre data-prefix=">" class="text-warning"><code>installing...</code></pre>
	<pre data-prefix=">" class="text-success"><code>Done!</code></pre>
</div>