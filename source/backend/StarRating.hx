package backend;

import haxe.ds.Map;
import Lambda; // 添加Lambda库支持

typedef RaSection = {
	var mustHitSection:Bool;
	var sectionNotes:Array<Array<Float>>;
}

typedef RaNote = {
	var time:Float;
	var lane:Int;
	var duration:Float;
	var isSlide:Bool;
}

class StarRating {
	private var playerNotes:Array<RaNote> = [];
	private var songSpeed:Float = 1.0;

	// 优化后的权重分配
	private static final WEIGHTS:Map<String, Float> = [
		"density" => 0.35,
		"strain" => 0.35,
		"pattern" => 0.25,
		"sliderComplexity" => 0.12,
		"handBalance" => 0.03
	];

	public function new() {}

	public function calculateFullDifficulty(songData:SwagSong):{rating:String, stars:Float} {
		processNotes(songData.notes);
		if (playerNotes.length < 5) return { rating: "Easy", stars: 0.0 };

		playerNotes.sort(sortNotes);
		this.songSpeed = songData.speed;

		var metrics = calculateAllMetrics();
		var rawDiff = combineMetrics(metrics);

		return getDifficultyRating(rawDiff);
	}

	//=== 核心逻辑 ===
	private function processNotes(sections:Array<RaSection>) {
		playerNotes = [];
		for (section in sections) {
			var isPlayer = section.mustHitSection;
			for (noteData in section.sectionNotes) {
				var lane = convertLane(Std.int(noteData[1]), isPlayer);
				if (lane == -1) continue;

				playerNotes.push({
					time: noteData[0],
					lane: lane,
					duration: noteData[2],
					isSlide: noteData[2] > 0
				});
			}
		}
	}

	private inline function convertLane(original:Int, isPlayer:Bool):Int {
		return if (isPlayer) {
			(original >= 0 && original <= 3) ? original : -1;
		} else {
			(original >= 4 && original <= 7) ? (original - 4) : -1;
		}
	}

	//=== 指标计算 ===
	private function calculateAllMetrics():Map<String, Float> {
		return [
			"density" => calculateDensity(),
			"strain" => calculateStrain(),
			"pattern" => calculatePatternComplexity(),
			"sliderComplexity" => calculateSliderComplexity(),
			"handBalance" => calculateHandBalance()
		];
	}

	private function calculateDensity():Float {
		if (playerNotes.length == 0) return 0.0;
		
		var totalTime = playerNotes[playerNotes.length - 1].time - playerNotes[0].time;
		var baseDensity = totalTime > 0 ? playerNotes.length / (totalTime / 1000) : 0.0;
		var maxComboBonus = calculateComboDensityBonus();
		var speedFactor = Math.pow(songSpeed, 2.5) + Math.log(songSpeed + 1);
		
		return normalizeValue(baseDensity * speedFactor * (1 + maxComboBonus), 10, 100);
	}

	private function calculateStrain():Float {
		var strainPeaks = [];
		var currentStrain = 0.0;
		var prevTime = -9999.0;
		var decayRate = 0.82;

		for (note in playerNotes) {
			var timeDiff = note.time - prevTime;
			var decay = Math.pow(decayRate, timeDiff / 200);
			currentStrain = currentStrain * decay + 1.0;
			strainPeaks.push(currentStrain);
			prevTime = note.time;
		}

		strainPeaks.sort(descendingSort);
		var threshold = calculatePeakThreshold(strainPeaks, 0.1);
		var topStrains = strainPeaks.filter(function(p) return p >= threshold);
		
		return normalizeValue(average(topStrains), 3.0, 35.0);
	}

	private function calculatePatternComplexity():Float {
		var patternMap = new Map<String, Int>();
		for (i in 1...playerNotes.length) {
			var delta = Math.abs(playerNotes[i].lane - playerNotes[i-1].lane);
			var key = Std.string(delta);
			patternMap[key] = patternMap.exists(key) ? patternMap[key] + 1 : 1;
		}

		var entropy = 0.0;
		var total = playerNotes.length - 1;
		for (count in patternMap) {
			var p = count / total;
			entropy -= p * Math.log(p);
		}
		return normalizeValue(entropy, 0.8, 5.0);
	}

	private function calculateSliderComplexity():Float {
		var totalDuration = 0.0;
		var sliderCount = 0;
		for (note in playerNotes) {
			if (note.isSlide) {
				totalDuration += note.duration;
				sliderCount++;
			}
		}
		var complexity = sliderCount * Math.log(totalDuration / 500 + 1);
		return normalizeValue(complexity, 0, 180);
	}

	private function calculateHandBalance():Float {
		// 修复count方法问题
		var leftCount = Lambda.count(playerNotes, function(n) return n.lane < 2);
		var imbalance = Math.abs(leftCount - (playerNotes.length - leftCount)) / playerNotes.length;
		return 1 - normalizeValue(imbalance, 0, 0.4);
	}

	//=== 工具方法 ===
	private function normalizeValue(value:Float, min:Float, max:Float):Float {
		var clamped = (value - min) / (max - min);
		clamped = Math.max(0, Math.min(1, clamped));
		return clamped < 0.8 ? clamped * 0.8 : 0.8 + (clamped - 0.8) * 2.0;
	}

	private function calculateComboDensityBonus():Float {
		var maxBonus = 0.0;
		var currentCombo = 0;
		for (note in playerNotes) {
			currentCombo = note.isSlide ? 0 : currentCombo + 1;
			if (currentCombo > 20) {
				maxBonus = Math.max(maxBonus, (currentCombo - 20) * 0.03);
			}
		}
		return Math.min(maxBonus, 0.6);
	}

	private function calculatePeakThreshold(arr:Array<Float>, percentile:Float):Float {
		if (arr.length == 0) return 0.0;
		
		// 修复索引类型问题
		var index:Int = Std.int(Math.floor(arr.length * percentile));
		return arr[Std.int(Math.min(index, arr.length - 1))];
	}

	private function average(arr:Array<Float>):Float {
		return arr.length == 0 ? 0.0 : Lambda.fold(arr, function(a, b) return a + b, 0.0) / arr.length; // 使用Lambda.fold
	}

	private function sortNotes(a:RaNote, b:RaNote):Int {
		return a.time < b.time ? -1 : 1;
	}

	private static function descendingSort(a:Float, b:Float):Int {
		return a < b ? 1 : a > b ? -1 : 0;
	}

	private function combineMetrics(metrics:Map<String, Float>):Float {
		var total = 0.0;
		for (key in WEIGHTS.keys()) {
			total += metrics.get(key) * WEIGHTS.get(key);
		}
		return total;
	}

	private function getDifficultyRating(raw:Float):{rating:String, stars:Float} {
		trace('raw: ' + raw);
		var stars = if (raw < 5.0) {
			Math.pow(raw, 1.2) * 2.5; //现在逻辑有问题，raw无法突破1，但是意外的运行还不错，就暂时不改了 -狐月影留
		} else {
			2.5 * Math.pow(5.0, 1.2) + Math.pow(raw - 5.0, 1.6) * 1.8;
		};
		trace('stars: ' + stars);
		stars = stars * 4;
		//stars = Math.min(stars, 10.0);
		stars = Math.round(stars * 100) / 100;

		return if (stars < 2.0) {
			{ rating: "Easy", stars: stars };
		} else if (stars < 4.0) {
			{ rating: "Normal", stars: stars };
		} else if (stars < 6.0) {
			{ rating: "Hard", stars: stars };
		} else if (stars < 8.0) {
			{ rating: "Insane", stars: stars };
		} else if (stars < 9.5) {
			{ rating: "Expert", stars: stars };
		} else {
			{ rating: "God", stars: stars };
		}
	}

	//=== 调试工具 ===
	public function debugMetrics(songData:SwagSong):Void {
		calculateFullDifficulty(songData);
		trace("=== Difficulty Metrics ===");
		trace('Density: ${calculateDensity()}');
		trace('Strain: ${calculateStrain()}');
		trace('Pattern: ${calculatePatternComplexity()}');
		trace('Sliders: ${calculateSliderComplexity()}');
		trace('Balance: ${calculateHandBalance()}');
		trace("==========================");
	}
}