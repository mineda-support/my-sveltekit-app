<script>
	
	let number;

	async function roll() {
		const response = await fetch("/development/test_roll");
		number = await response.json();
	}
</script>

<button on:click={roll}>Roll the dice</button>

{#if number !== undefined}
	<p>You rolled a {number}</p>
{/if}

